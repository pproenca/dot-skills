---
title: Use multiprocessing for CPU-Bound Parallelism
impact: HIGH
impactDescription: 4-8× speedup on multi-core systems
tags: conc, multiprocessing, cpu-bound, parallelism
---

## Use multiprocessing for CPU-Bound Parallelism

The GIL prevents true parallelism in threads for CPU-bound work. Use `multiprocessing` to bypass the GIL and utilize multiple cores.

**Incorrect (GIL-limited threading):**

```python
from concurrent.futures import ThreadPoolExecutor

def compute_hashes(data_chunks: list[bytes]) -> list[str]:
    def hash_chunk(chunk: bytes) -> str:
        return hashlib.sha256(chunk).hexdigest()

    with ThreadPoolExecutor(max_workers=4) as executor:
        return list(executor.map(hash_chunk, data_chunks))
    # GIL prevents parallel execution - effectively single-threaded
```

**Correct (true parallelism):**

```python
from concurrent.futures import ProcessPoolExecutor

def compute_hashes(data_chunks: list[bytes]) -> list[str]:
    def hash_chunk(chunk: bytes) -> str:
        return hashlib.sha256(chunk).hexdigest()

    with ProcessPoolExecutor(max_workers=4) as executor:
        return list(executor.map(hash_chunk, data_chunks))
    # Each process has its own GIL - true parallel execution
```

**Alternative (for large data):**

```python
import multiprocessing as mp

def compute_hashes_large(data_chunks: list[bytes]) -> list[str]:
    with mp.Pool(processes=4) as pool:
        return pool.map(hash_chunk, data_chunks, chunksize=100)
    # chunksize reduces IPC overhead for many small items
```

**When NOT to use multiprocessing:**
- I/O-bound tasks (use asyncio instead)
- Small datasets (process startup overhead dominates)
- When sharing large state between workers

Reference: [multiprocessing documentation](https://docs.python.org/3/library/multiprocessing.html)
