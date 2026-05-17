---
title: Read or Stat Files Outside Tight Loops
impact: HIGH
impactDescription: O(n) syscalls eliminated — 10-100× speedup on disk-bound code
tags: io, filesystem, syscall, caching, batching
---

## Read or Stat Files Outside Tight Loops

Every `open()`, `read()`, `stat()`, `exists()` is a kernel transition. On a hot path, syscalls dominate runtime even when the data is in OS page cache — the user→kernel→user trip costs microseconds that add up to seconds at N=100k. The right pattern is one of: (1) read the file once outside the loop, (2) bulk-walk the directory with a single `os.scandir` / `fs.readdir`, or (3) memoize the result if it can't change during the run. The wrong pattern is "re-check the config file" or "open this template" inside each iteration of a request handler.

**Incorrect (re-read per iteration — N syscalls):**

```python
# Render each row through the same template — file read N times
for row in rows:                                # 50,000 rows
    with open('template.txt') as f:             # syscall per row
        template = f.read()
    print(template.format(**row))
```

**Correct (hoist the read — 1 syscall):**

```python
with open('template.txt') as f:                 # once
    template = f.read()
for row in rows:
    print(template.format(**row))
```

**Alternative (caching when reads must respect mtime):**

```python
from functools import lru_cache
import os

@lru_cache(maxsize=128)
def _load_template(path, mtime):
    with open(path) as f:
        return f.read()

def load_template(path):
    return _load_template(path, os.stat(path).st_mtime)
# First load: 2 syscalls (stat + read). Subsequent: 1 syscall (stat only).
```

**When NOT to use this pattern:**
- When the file is genuinely expected to change during the loop (log tail, control file). Then the per-iteration cost is intrinsic — consider inotify/FSEvents instead of polling.

Reference: [Python `os.scandir` is faster than `listdir`+`stat` because it avoids the per-entry syscall](https://docs.python.org/3/library/os.html#os.scandir)
