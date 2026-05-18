---
title: Spill to Temp Files; Don't Use BytesIO for Out-of-Memory Buffers
impact: HIGH
impactDescription: prevents OOM; spill cost ~O(disk write time) not O(process death)
tags: spill, tempfile, bytesio, spooled, disk
---

## Spill to Temp Files; Don't Use BytesIO for Out-of-Memory Buffers

`io.BytesIO` is a file-shaped API backed entirely by RAM — convenient, until the buffer grows past memory and the process dies. When the size is unbounded or *might* exceed RAM, you want spill discipline: start in memory for speed, transparently swap to a temp file once you cross a threshold. Python's `tempfile.SpooledTemporaryFile` does exactly this; `tempfile.NamedTemporaryFile` is fine when you know you'll exceed RAM. Either way, the rule is: if the size depends on input you don't control, the buffer must spill.

**Incorrect (BytesIO; size depends on upstream — OOM on large input):**

```python
import io, requests

# What if the response is 50 GB? BytesIO grows to 50 GB of RAM. Process dies.
buf = io.BytesIO()
with requests.get(url, stream=True) as resp:
    for chunk in resp.iter_content(chunk_size=1024 * 1024):
        buf.write(chunk)
process(buf)
```

**Correct (`SpooledTemporaryFile` — RAM-fast for small, disk-safe for large):**

```python
import tempfile, requests

# Stays in memory up to 32 MiB, then transparently spills to a scratch file on disk.
with tempfile.SpooledTemporaryFile(max_size=32 * 1024 * 1024) as buf:
    with requests.get(url, stream=True) as resp:
        for chunk in resp.iter_content(chunk_size=1024 * 1024):
            buf.write(chunk)
    buf.seek(0)
    process(buf)
# Spill file is cleaned up on context exit.
```

**For known-large output — go straight to a named temp file:**

```python
import tempfile, os

# Lives on disk; survives the process if you want; auto-deleted when closed.
with tempfile.NamedTemporaryFile(prefix="export_", suffix=".parquet", delete=True) as export_file:
    write_huge_parquet(export_file.name)
    upload_to_s3(export_file.name)
```

**Pick the temp dir explicitly — `/tmp` may be a tiny tmpfs:**

```python
# Default uses TMPDIR or /tmp; in containers /tmp can be a memory-backed tmpfs.
# Override with TMPDIR or the `dir` arg to put spill on real disk.
spill_dir = os.environ.get("SPILL_DIR", "/var/tmp/spill")
os.makedirs(spill_dir, exist_ok=True)
with tempfile.SpooledTemporaryFile(max_size=64 * 1024 * 1024, dir=spill_dir) as buf:
    ...
```

**Watch for "hidden" BytesIO usage:**

```python
# requests' `Response.content` materializes the whole body to memory.
resp = requests.get(url).content      # entire body in RAM

# `BytesIO(blob.download_as_bytes())` and `io.BytesIO(s3_object.read())` — same issue.
# Stream instead: iter_content / Body.iter_chunks / streaming download APIs.
```

**When BytesIO is fine:**
- The size is known and small (< few MB) — protocol headers, small JSON payloads
- It's a one-shot test/fixture, not a production path

Reference: [Python docs — tempfile.SpooledTemporaryFile](https://docs.python.org/3/library/tempfile.html#tempfile.SpooledTemporaryFile), [requests — Streaming requests](https://docs.python-requests.org/en/latest/user/advanced/#body-content-workflow)
