---
title: Leverage Parallel Scanning with Threads
impact: MEDIUM
impactDescription: utilizes multi-core CPUs for faster scans
tags: perf, threads, parallel, cli
---

## Leverage Parallel Scanning with Threads

ast-grep scans files in parallel by default. Tune thread count for optimal performance on your hardware and codebase size.

**Incorrect (single-threaded on large codebase):**

```bash
ast-grep scan -c sgconfig.yml -j 1  # Forces single thread
```

**Correct (use optimal thread count):**

```bash
# Let ast-grep choose (default - usually optimal)
ast-grep scan -c sgconfig.yml

# Explicit for CPU-bound machines
ast-grep scan -c sgconfig.yml -j 8  # 8 threads

# Check available cores
ast-grep scan -c sgconfig.yml -j $(nproc)
```

**Thread tuning guidelines:**
- Default heuristic works well for most cases
- I/O-bound (SSD): More threads than cores can help
- CPU-bound (complex rules): Match thread count to cores
- Memory-constrained: Reduce threads to lower peak memory

**CI/CD optimization:**

```yaml
# GitHub Actions example
- name: Lint with ast-grep
  run: |
    ast-grep scan -c sgconfig.yml -j 4 --json > results.json
```

**Measuring performance:**

```bash
# Time the scan
time ast-grep scan -c sgconfig.yml

# Compare thread counts
time ast-grep scan -c sgconfig.yml -j 1
time ast-grep scan -c sgconfig.yml -j 4
time ast-grep scan -c sgconfig.yml -j 8
```

Reference: [CLI Reference](https://ast-grep.github.io/reference/cli.html)
