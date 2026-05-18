---
title: Default to zstd or lz4; Treat gzip as Legacy
impact: MEDIUM
impactDescription: 2-10x faster decode; 10-30% better ratio
tags: codec, compression, zstd, lz4, gzip
---

## Default to zstd or lz4; Treat gzip as Legacy

gzip is fine — for 1995. zstd matches gzip's compression ratio at 2–5× faster decode and offers a tunable level that can beat gzip on both axes. lz4 is even faster (often 5–10× decode), trades ~10–20 % ratio, and is the right default when the bottleneck is CPU (compress/decompress dominates wall-clock). snappy sits between lz4 and gzip — fast but losing ground to zstd in practice. The wrong codec is invisible but costs 30–80 % of throughput on a CPU-bound decoder loop; pick by access pattern, not muscle memory.

**Incorrect (gzip everywhere by reflex):**

```python
import gzip
# gzip is the slowest mainstream codec at any given ratio.
with gzip.open("events.json.gz", "rb") as f:
    for line in f:
        process(line)
```

**Correct (pick by access pattern):**

```python
import zstandard as zstd

# zstd at level 3 (default): gzip-like ratio, 3-5x faster decode.
ctx = zstd.ZstdDecompressor()
with open("events.json.zst", "rb") as f, ctx.stream_reader(f) as stream:
    for line in stream:
        process(line)
```

```python
# lz4 frame format: fastest decode; right for streaming pipelines where ratio matters less.
import lz4.frame
with lz4.frame.open("events.json.lz4", "rb") as f:
    for line in f:
        process(line)
```

**For Parquet — zstd or snappy, not gzip:**

```python
import pyarrow.parquet as pq

# Parquet's column-level compression: snappy is the historical default (fast, ok ratio).
# zstd typically wins on ratio at comparable speed; pick zstd unless you have a reason.
pq.write_table(table, "events.parquet", compression="zstd", compression_level=3)
```

**Picking the codec:**

| Codec | Ratio | Decompress speed | Use when |
|---|---|---|---|
| **lz4** | ~1.7× | ~3000 MB/s | CPU-bound; you'll re-read many times; throughput > size |
| **snappy** | ~2× | ~1500 MB/s | Parquet/Avro default; balanced |
| **zstd L3** | ~2.8× | ~1500 MB/s | Best general-purpose; matches gzip ratio at 3-5× speed |
| **zstd L19** | ~3.5× | ~1500 MB/s | Cold-storage archives; pay compression once |
| **gzip** | ~2.7× | ~400 MB/s | Compatibility only (HTTP, legacy tools) |

(Numbers vary by data; relative ordering is consistent.)

**Match the codec to the workload:**
- Hot path, recompressed often → lz4 or zstd L1–3
- Warm data, scanned occasionally → zstd L3–9
- Cold archive, decoded rarely → zstd L19+ or zstd long-range mode
- Cross-system interop / browser → gzip or brotli (HTTP) only

**When NOT to compress at all:**
- Data is already compressed (JPEG, MP4, .parquet with column compression on)
- CPU is the bottleneck and bytes-on-disk isn't (e.g., on a fast NVMe)

Reference: [zstd benchmarks](https://github.com/facebook/zstd#benchmarks), [LZ4 benchmarks](https://github.com/lz4/lz4#benchmarks), [Parquet compression](https://parquet.apache.org/docs/file-format/data-pages/compression/)
