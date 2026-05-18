---
title: Use Zero-Copy When Moving Bytes As-Is
impact: CRITICAL
impactDescription: 2-4x throughput on bulk transfers; 50% CPU reduction
tags: io, zero-copy, sendfile, copy-file-range, splice
---

## Use Zero-Copy When Moving Bytes As-Is

When you copy a file or stream bytes between two fds *without inspecting them*, the naive loop pays for four copies: disk → kernel page cache → userspace buffer → kernel socket buffer → NIC. The Linux `sendfile`, `copy_file_range`, and `splice` syscalls hand the pages directly between kernel objects, skipping the userspace round-trip entirely — half the CPU, half the memory bandwidth, and no buffer allocation. Python exposes the relevant ones via `os.sendfile`, `os.copy_file_range`, and `shutil.copyfile` (which uses them under the hood on modern kernels).

**Incorrect (read into userspace, write back out):**

```python
# 4 copies, 2 syscalls per chunk, full userspace bandwidth used.
with open(src, "rb") as fin, open(dst, "wb") as fout:
    while chunk := fin.read(1024 * 1024):
        fout.write(chunk)
```

**Correct (let the kernel move the bytes):**

```python
# File → file: copy_file_range stays inside the kernel (and supports reflinks on btrfs/XFS).
# Linux-only (Python 3.8+); on macOS use shutil.copyfile, which picks the best primitive.
import os

with open(src, "rb") as fin, open(dst, "wb") as fout:
    size = os.fstat(fin.fileno()).st_size
    remaining = size
    while remaining > 0:
        # Leaves offset args as None → uses each fd's current offset, which advances automatically.
        copied = os.copy_file_range(fin.fileno(), fout.fileno(), remaining)
        if copied == 0:
            break                               # source exhausted
        remaining -= copied
```

**File → socket: `sendfile`:**

```python
# Common pattern: serve a static file over a socket.
def send_file(sock, fileobj):
    size = os.fstat(fileobj.fileno()).st_size
    offset = 0
    while offset < size:
        sent = os.sendfile(sock.fileno(), fileobj.fileno(), offset, size - offset)
        if sent == 0:
            break
        offset += sent
```

**Most of the time, the stdlib helper is enough — and it picks the best primitive:**

```python
import shutil
shutil.copyfile(src, dst)   # uses copy_file_range / sendfile / fcopyfile when available
```

**When NOT to use zero-copy:**
- You need to inspect or transform the bytes — then you must read them into userspace anyway
- Files are tiny (a few KB) — the syscall overhead dominates either way
- Cross-filesystem on older kernels — `copy_file_range` may fall back to plain copy or fail with `EXDEV`; check the return value

Reference: [Linux man — sendfile(2)](https://man7.org/linux/man-pages/man2/sendfile.2.html), [Linux man — copy_file_range(2)](https://man7.org/linux/man-pages/man2/copy_file_range.2.html), [Python docs — os.sendfile / copy_file_range](https://docs.python.org/3/library/os.html#os.sendfile)
