---
title: Prefer Sequential Reads Over Random
impact: CRITICAL
impactDescription: 10-100x throughput on HDD; 2-10x on SSD
tags: io, sequential-access, readahead, page-cache, fadvise
---

## Prefer Sequential Reads Over Random

The OS aggressively prefetches sequential reads — by the time your code asks for byte N, the kernel has already pulled byte N + 128 KiB into the page cache. Random reads defeat readahead, force one disk seek per request on rotational media, and on SSDs still pay the per-IOP latency floor (~50–100 µs). A workload that scans a 1 GB file sequentially in 1 s often takes 60 s with random access — same bytes, same drive. Design the access pattern around sequential scans whenever possible, and *tell* the kernel when you're being sequential or random with `posix_fadvise`.

**Incorrect (jumps around the file; defeats readahead):**

```python
# Random offsets read one cache line at a time and rotate the page cache uselessly.
offsets = load_index("offsets.bin")  # millions of byte offsets, unsorted
with open("data.bin", "rb") as f:
    for off in offsets:
        f.seek(off)
        record = f.read(64)
        process(record)
```

**Correct (sort offsets to make the pattern sequential; advise the kernel):**

```python
import os

# Sorting offsets turns N random seeks into one sequential scan with skips.
offsets = sorted(load_index("offsets.bin"))

with open("data.bin", "rb") as f:
    fd = f.fileno()
    os.posix_fadvise(fd, 0, 0, os.POSIX_FADV_SEQUENTIAL)   # ask for aggressive readahead
    for off in offsets:
        f.seek(off)
        record = f.read(64)
        process(record)
```

**Warning — sorting changes the output order:**

`sorted(offsets)` forces the entire offset array into memory (O(N) RAM) and emits records in *offset order*, not *query order*. If the downstream consumer relies on the original query order, either keep the original index for a post-sort, or sort `[(off, query_idx) for ...]` pairs and re-sort the results by `query_idx` at the end. Skip the sort entirely if N exceeds the offset-array memory budget.

**When random truly is the access pattern, tell the kernel and use mmap:**

```python
import mmap, os

with open("data.bin", "rb") as f:
    fd = f.fileno()
    os.posix_fadvise(fd, 0, 0, os.POSIX_FADV_RANDOM)       # disable readahead
    mm = mmap.mmap(fd, 0, prot=mmap.PROT_READ)
    for off in random_offsets:
        record = mm[off:off+64]
        process(record)
```

**Watch for accidental random patterns:**
- Reading rows from a Parquet file by row index without sorting — turns a single-pass scan into many small reads
- Joining unsorted data on a sorted-index column — sort the probe side first or use a hash join
- `glob.glob()` order ≠ on-disk order — readdir order can be effectively random for the filesystem

Reference: [Linux man — posix_fadvise(2)](https://man7.org/linux/man-pages/man2/posix_fadvise.2.html), [Brendan Gregg — File system caches](https://www.brendangregg.com/blog/2014-04-09/free-memory-cache-confusion.html)
