---
title: Use External Merge Sort When The Input Doesn't Fit In Memory
impact: MEDIUM-HIGH
impactDescription: OOM or thrashing to bounded O(M) memory — sort a 1 TB file on an 8 GB box
tags: scale, external-sort, merge-sort, out-of-core
---

## Use External Merge Sort When The Input Doesn't Fit In Memory

In-memory `sorted()` works until the input doesn't fit in RAM — at which point it OOMs, swaps the machine into thrashing oblivion, or fails the Linux OOM killer test. **External merge sort** handles datasets vastly larger than RAM: split the input into M-sized chunks, sort each chunk in memory and write to disk (the "run formation" phase), then merge the runs k-way using a heap (the "merge" phase). Total I/O is ~2·n bytes per pass, with `ceil(log_k(n/M))` passes — typically 1-2 in practice.

This is **the** algorithm for big-data sort: Hadoop MapReduce shuffle, the original Google MapReduce, `sort -m`, every database query engine's external `ORDER BY` and `GROUP BY`, terabyte-scale ETL.

**Incorrect (sort a 1 TB file in memory — OOM):**

```python
def sort_huge_file(in_path: str, out_path: str) -> None:
    # Reads all 10⁹ lines into memory. On a 1 TB file with 100-byte lines that's
    # ~100 GB Python overhead — process gets killed by OOM in seconds.
    with open(in_path) as f:
        lines = f.readlines()
    lines.sort()
    with open(out_path, "w") as f:
        f.writelines(lines)
```

**Correct (external merge sort — bounded memory, two passes for typical data):**

```python
import heapq, os, tempfile
from contextlib import ExitStack

def external_sort(in_path: str, out_path: str, chunk_lines: int = 1_000_000) -> None:
    # Phase 1: run formation. Read `chunk_lines` at a time, sort in memory, spill as a run file.
    run_paths: list[str] = []
    with open(in_path) as f:
        chunk: list[str] = []
        for line in f:
            chunk.append(line)
            if len(chunk) >= chunk_lines:
                run_paths.append(_write_sorted_run(chunk))
                chunk = []
        if chunk:
            run_paths.append(_write_sorted_run(chunk))

    # Phase 2: k-way merge using a heap. Memory is O(k) lines (one per open run).
    with ExitStack() as stack, open(out_path, "w") as out:
        files = [stack.enter_context(open(p)) for p in run_paths]
        for line in heapq.merge(*files):
            out.write(line)
    for p in run_paths:
        os.unlink(p)

def _write_sorted_run(chunk: list[str]) -> str:
    chunk.sort()
    fd, path = tempfile.mkstemp(prefix="run-", suffix=".txt")
    with os.fdopen(fd, "w") as f:
        f.writelines(chunk)
    return path
```

**Two-pass vs many-pass:** the number of runs k is `ceil(n / chunk_lines)`. Most filesystems and OSs handle thousands of open files fine; for k > ~1000, the merge phase needs **cascading merges** (merge first 1000 runs into one, repeat) — each cascade is a fresh sequential pass.

**Replacement selection** doubles average run length: keep an in-memory min-heap; as you emit the smallest item, immediately read the next input item — if it's larger than what you just emitted, it joins the current run, otherwise it goes into a "next run" heap. Average run becomes ~2M items instead of M, halving the number of merge passes for sorted-ish input.

**Sort-merge join is the same idea applied to joins:** sort both inputs externally on the join key, then walk them in lockstep. The textbook approach for joining datasets too large for hash-join.

**When NOT to use:**

- The data fits in memory (just use `sorted()`)
- The data is *almost* sorted — Timsort exploits existing order in O(n) for run detection. External sort still does full passes.
- The data has bounded-range integer keys — external counting / radix sort can outperform comparison-based external sort.

**Production:** Hadoop MapReduce shuffle (sort by reduce key), Spark `sortByKey`, PostgreSQL's external sort for large `ORDER BY` / `GROUP BY` / `DISTINCT`, BigQuery shuffle, Unix `sort` (uses external merge for files exceeding `LC_ALL`-sized buffers).

Reference: [External sorting — Wikipedia](https://en.wikipedia.org/wiki/External_sorting)
