---
title: Isolate Parallel Worker Directories
impact: MEDIUM
impactDescription: unsafe parallelism causes file corruption in shared directories, producing non-deterministic results across all concurrent workers
tags: exec, parallelism, workers, concurrency, isolation
---

## Parallel Execution

Mutations can run concurrently to reduce total mutation testing time. The per-mutation directory structure enables safe parallelism without locks, as long as each mutation stays within its own directory.

### Spec Requirements

- **Workers may run concurrently.** The `--workers` flag controls the maximum number of parallel mutation workers.
- Each mutation must **write only inside its own directory** (`<work-dir>/<mutation-id>/`).
- Values less than 1 for `--workers` must be treated as 1 (sequential execution).

### Why Directory Isolation Enables Parallelism

Each mutation has its own `feature.json` and `generated/` directory. Two workers processing m1 and m2 simultaneously never touch the same files. This eliminates race conditions without file locking, mutexes, or coordination between workers.

### What Must Not Be Shared

- The **base IR** must not be modified (per the deep-copy requirement). Workers read from it but never write to it.
- The **work directory root** must not have files that workers compete to write.
- **Standard output/error** should be captured per-mutation, not written to a shared console during execution (reports are emitted after all mutations complete).

### Examples

**Incorrect (shared work directory -- workers overwrite each other's files):**

```sh
# Worker 1 and Worker 2 both write to the same directory
# Worker 1:
cp mutated-m1.json build/acceptance-mutation/feature.json
# Worker 2 overwrites before Worker 1 reads:
cp mutated-m2.json build/acceptance-mutation/feature.json
# Worker 1 now generates tests from m2's IR, not m1's
```

**Correct (per-mutation directories -- workers are fully isolated):**

```sh
# Worker 1 writes only to m1's directory
cp mutated-m1.json build/acceptance-mutation/m1/feature.json
acceptance-generator build/acceptance-mutation/m1/feature.json \
  build/acceptance-mutation/m1/generated/a-feature_test.ext

# Worker 2 writes only to m2's directory (no conflict)
cp mutated-m2.json build/acceptance-mutation/m2/feature.json
acceptance-generator build/acceptance-mutation/m2/feature.json \
  build/acceptance-mutation/m2/generated/a-feature_test.ext
```

### Why This Matters

Mutation testing can be slow — each mutation requires generating tests and running them. For a feature with 50 mutations and a test suite that takes 2 seconds per run, sequential execution takes 100 seconds. With 4 workers, it takes ~25 seconds. Parallel execution makes mutation testing practical for CI integration.

The `--workers` flag lets developers tune the trade-off between speed and resource usage based on their hardware and test suite characteristics.
