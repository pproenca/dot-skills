---
title: Stream HTTP Response Bodies; Never Materialize the Whole Body
impact: CRITICAL
impactDescription: from O(body size) RAM to O(chunk) RAM; prevents OOM on large downloads
tags: io, http, streaming, requests, httpx
---

## Stream HTTP Response Bodies; Never Materialize the Whole Body

`requests.get(url).content` reads the *entire* response body into RAM before returning a single byte to your code. For a 5 GB download on a 2 GB container, that's a guaranteed OOM kill — and even when it fits, peak RSS spikes by the full body size for the duration of the call. The fix is one parameter: `stream=True`, plus an `iter_content` loop that yields chunks. The bytes still cross the wire; they just never all live in your process at once. Same trick for `httpx`, `urllib3`, `aiohttp` — every modern HTTP client has it; using the default eager path is what kills jobs.

**Incorrect (full body materialized in RAM before any processing):**

```python
import requests

# 5 GB body → 5 GB RAM spike → OOM kill.
resp = requests.get(url)             # default streams=False
with open("download.bin", "wb") as f:
    f.write(resp.content)             # the whole body is already in memory by now
```

**Correct (stream=True + iter_content; peak ≈ chunk_size):**

```python
import requests

# Body flows through the chunk loop; process RAM never holds more than chunk_size.
with requests.get(url, stream=True, timeout=60) as resp:
    resp.raise_for_status()
    with open("download.bin", "wb") as f:
        for chunk in resp.iter_content(chunk_size=1024 * 1024):     # 1 MiB chunks
            if chunk:                                                # filter keep-alives
                f.write(chunk)
```

**For JSON-lines / NDJSON over HTTP — `iter_lines` is the right shape:**

```python
import requests, json

with requests.get(url, stream=True, timeout=60) as resp:
    resp.raise_for_status()
    for line in resp.iter_lines(decode_unicode=False):
        if line:
            record = json.loads(line)
            process(record)
# Same body-too-big-for-RAM problem solved with line-level granularity.
```

**With `httpx` (sync or async) — same idea, different name:**

```python
import httpx

# Sync streaming.
with httpx.stream("GET", url, timeout=60) as resp:
    resp.raise_for_status()
    with open("download.bin", "wb") as f:
        for chunk in resp.iter_bytes(chunk_size=1024 * 1024):
            f.write(chunk)
```

```python
# Async streaming.
import httpx, asyncio

async def download(url, dst):
    async with httpx.AsyncClient() as client:
        async with client.stream("GET", url, timeout=60) as resp:
            resp.raise_for_status()
            with open(dst, "wb") as f:
                async for chunk in resp.aiter_bytes(chunk_size=1024 * 1024):
                    f.write(chunk)
```

**With `aiohttp` (always async):**

```python
import aiohttp

async with aiohttp.ClientSession() as session:
    async with session.get(url, timeout=aiohttp.ClientTimeout(total=60)) as resp:
        resp.raise_for_status()
        with open("download.bin", "wb") as f:
            async for chunk in resp.content.iter_chunked(1024 * 1024):
                f.write(chunk)
```

**Watch for hidden `.content` / `.read()` calls:**

```python
# Boto3 S3: get_object()["Body"] is a streaming wrapper — don't .read() the whole thing.
obj = s3.get_object(Bucket=bucket, Key=key)
for chunk in obj["Body"].iter_chunks(chunk_size=1024 * 1024):     # streaming
    process(chunk)
# obj["Body"].read() — same OOM trap as requests.content.
```

**Picking chunk_size:**
- 256 KiB – 4 MiB is a healthy range; align to a multiple of 4 KiB (page size)
- Smaller is fine for line-oriented data (let `iter_lines` decide boundaries)
- Don't go below 8 KiB — per-chunk syscall / TLS-record overhead dominates

**When eager loading is fine:**
- Bodies are small and bounded (JSON API responses < a few MB, status pages)
- You need random access to the body and have RAM to spare
- One-off scripts where wall-clock matters more than memory ceiling

Reference: [Requests — Streaming requests](https://docs.python-requests.org/en/latest/user/advanced/#body-content-workflow), [httpx — Streaming responses](https://www.python-httpx.org/quickstart/#streaming-responses), [aiohttp — Streaming response content](https://docs.aiohttp.org/en/stable/streams.html)
