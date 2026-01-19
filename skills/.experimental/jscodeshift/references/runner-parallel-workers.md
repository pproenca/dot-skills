---
title: Configure Worker Count for Optimal Parallelization
impact: LOW-MEDIUM
impactDescription: 2-4× speedup on multi-core systems
tags: runner, parallel, workers, performance
---

## Configure Worker Count for Optimal Parallelization

jscodeshift runs transforms in parallel across multiple workers. Configure worker count based on available CPU cores.

**Incorrect (default worker count may be suboptimal):**

```bash
# Default uses 1 worker per CPU core
jscodeshift -t transform.js src/

# On I/O-heavy transforms, this may leave cores idle
# On memory-heavy transforms, this may cause swapping
```

**Correct (tune workers to workload):**

```bash
# For CPU-intensive transforms (complex AST manipulation)
# Use core count - 1 to leave headroom
jscodeshift --cpus=7 -t transform.js src/  # On 8-core machine

# For I/O-intensive transforms (many small files)
# Can exceed core count since workers wait on I/O
jscodeshift --cpus=12 -t transform.js src/

# For memory-heavy transforms (large files)
# Reduce workers to avoid memory pressure
jscodeshift --cpus=4 -t transform.js src/
```

**Benchmarking approach:**

```bash
# Time with different worker counts
time jscodeshift --cpus=1 -t transform.js src/
time jscodeshift --cpus=4 -t transform.js src/
time jscodeshift --cpus=8 -t transform.js src/
time jscodeshift --cpus=16 -t transform.js src/

# Find the sweet spot for your transform and codebase
```

**Alternative (single-threaded for debugging):**

```bash
# Run single-threaded for easier debugging
jscodeshift --cpus=1 -t transform.js src/

# Or completely disable workers
jscodeshift --run-in-band -t transform.js src/
```

Reference: [jscodeshift CLI Options](https://github.com/facebook/jscodeshift#usage-cli)
