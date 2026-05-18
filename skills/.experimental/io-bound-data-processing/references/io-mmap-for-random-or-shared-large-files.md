---
title: Use mmap for Random Access or Shared Read-Mostly Files
impact: CRITICAL
impactDescription: 10-100x faster random access; zero-copy
tags: io, mmap, virtual-memory, zero-copy, page-cache
---

## Use mmap for Random Access or Shared Read-Mostly Files

`mmap` maps a file into the process's address space — the bytes appear as a `bytes`-like object, but no read happens until you touch a page, and pages are shared with the kernel's page cache instead of being copied. For random access this gives near-RAM latency on hot pages and one disk read per cold page (no buffering, no userspace allocation), and for read-mostly files shared across processes or runs, the page cache caches the file *once* for all of them. The cost is opaque latency on cold pages and no help for sequential scans (the buffered reader is just as fast and simpler).

**Incorrect (random seeks + `read()` allocate a fresh bytes object per call):**

```python
# 4 syscalls + 4 allocations per record; cold cache → 4 disk reads per record.
with open("index.bin", "rb") as f:
    for query_id in queries:
        f.seek(query_id * RECORD_SIZE)
        record = f.read(RECORD_SIZE)
        process(record)
```

**Correct (map once; random access is a pointer dereference):**

```python
import mmap

with open("index.bin", "rb") as f:
    mm = mmap.mmap(f.fileno(), 0, prot=mmap.PROT_READ)
    for query_id in queries:
        off = query_id * RECORD_SIZE
        record = mm[off:off + RECORD_SIZE]   # zero-copy slice; pages faulted in on demand
        process(record)
    mm.close()
```

**Shared across processes — the page cache deduplicates:**

```python
# Process A and Process B both mmap "index.bin".
# Their address spaces point at the same physical pages — file is read off disk once.
mm_a = mmap.mmap(open("index.bin").fileno(), 0, prot=mmap.PROT_READ)
mm_b = mmap.mmap(open("index.bin").fileno(), 0, prot=mmap.PROT_READ)
```

**For writes — mmap with `ACCESS_WRITE` lets you mutate in place:**

```python
with open("data.bin", "r+b") as f:
    mm = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_WRITE)
    mm[0:4] = struct.pack("<I", new_value)
    mm.flush()   # not strictly required — kernel will write back, but flush forces durability
```

**When NOT to use mmap:**
- Sequential scans — `BufferedReader` with a 64 KiB buffer is as fast and simpler
- Files that don't fit in the address space on 32-bit systems (largely historical)
- Network filesystems with weak `mmap` semantics (NFS without `MAP_SHARED` coherence)
- Hot-loop random writes — `pwrite()` is often saner; mmap dirty-page flushing is opaque

Reference: [Linux man — mmap(2)](https://man7.org/linux/man-pages/man2/mmap.2.html), [Python docs — mmap](https://docs.python.org/3/library/mmap.html)
