---
title: Wrap Raw File Descriptors with a Buffered Reader/Writer
impact: CRITICAL
impactDescription: 10-1000x fewer syscalls
tags: io, buffering, syscalls, file-descriptors
---

## Wrap Raw File Descriptors with a Buffered Reader/Writer

Every `read()` and `write()` on a raw file descriptor is a syscall — a context switch into the kernel and back, ~1 µs even on a fast box. Calling `f.read(1)` a million times costs a *second* of pure syscall overhead before any I/O happens. A buffered wrapper amortizes that by reading 8–64 KiB blocks and serving small requests from the buffer; the syscall count drops by 3–4 orders of magnitude with no other code change. Python's `open()` returns a buffered wrapper by default — but `os.open()`, sockets, and many third-party APIs don't.

**Incorrect (unbuffered raw fd; one syscall per record):**

```python
import os

fd = os.open("records.bin", os.O_RDONLY)
records = []
while True:
    chunk = os.read(fd, 32)        # one syscall per 32-byte record
    if not chunk:
        break
    records.append(chunk)
os.close(fd)
```

**Correct (buffered wrapper amortizes syscalls):**

```python
import os, io

fd = os.open("records.bin", os.O_RDONLY)
records = []
with io.FileIO(fd, "r", closefd=True) as raw, io.BufferedReader(raw, buffer_size=65_536) as bf:
    while chunk := bf.read(32):    # one syscall per ~2000 records
        records.append(chunk)
```

**For writes, always wrap and flush deliberately:**

```python
with open("out.bin", "wb", buffering=1024 * 1024) as f:   # 1 MiB write buffer
    for record in records:
        f.write(record)
    # closing flushes; for long-running writers, call f.flush() at logical boundaries.
```

**For sockets, use `makefile()` or asyncio streams — never `recv(1)` in a loop:**

```python
# Wraps a socket with the same buffered protocol as a file.
with sock.makefile("rb", buffering=65_536) as bf:
    header = bf.read(16)
    body   = bf.read(struct.unpack("<I", header[:4])[0])
```

**Sizing rule of thumb:**
- Reads: 64 KiB is a good default; align to page size (4 KiB) or larger
- Writes: 1 MiB is a reasonable default for bulk output; smaller increases syscall count, larger increases latency-to-durability

Reference: [Python docs — io.BufferedReader](https://docs.python.org/3/library/io.html#io.BufferedReader), [Linux man — read(2)](https://man7.org/linux/man-pages/man2/read.2.html)
