---
title: Create Isolated Work Directories
impact: MEDIUM
impactDescription: wrong directory structure causes file collisions across mutations, corrupting results for up to N concurrent workers
tags: exec, work-directory, mutation-id, file-layout
---

## Work Directory Structure

Each mutation gets its own isolated work directory. This structure ensures mutations do not interfere with each other and makes cleanup straightforward.

### Spec Requirements

For each mutation, create a work directory:

```text
<work-dir>/<mutation-id>/
```

Write the mutated JSON IR to:

```text
<work-dir>/<mutation-id>/feature.json
```

Place generated tests under:

```text
<work-dir>/<mutation-id>/generated/
```

### Example Layout

For `--work-dir build/acceptance-mutation` with mutations m1, m2, m3:

```text
build/acceptance-mutation/
  m1/
    feature.json          # Mutated IR for m1
    generated/            # Generated tests from m1's IR
      a-feature_test.ext
  m2/
    feature.json
    generated/
      a-feature_test.ext
  m3/
    feature.json
    generated/
      a-feature_test.ext
```

### Why Per-Mutation Directories

If multiple mutations shared a directory, concurrent workers would overwrite each other's `feature.json` and generated test files. Per-mutation directories provide natural isolation without file-locking complexity.

This structure also aids debugging: when a mutation survives, the developer can inspect `build/acceptance-mutation/m3/feature.json` to see exactly what the mutated IR looks like, and `build/acceptance-mutation/m3/generated/` to see what tests were generated from it.

### Examples

**Incorrect (flat directory -- all mutations share a single directory):**

```text
build/acceptance-mutation/
  feature.json            # Overwritten by each mutation
  generated/
    a-feature_test.ext    # Overwritten by each mutation
```

**Correct (per-mutation isolation -- each mutation gets its own subdirectory):**

```text
build/acceptance-mutation/
  m1/
    feature.json
    generated/
      a-feature_test.ext
  m2/
    feature.json
    generated/
      a-feature_test.ext
```

### Why This Matters

The work directory is the mutation's entire execution context. The generator reads `feature.json` from it, writes generated tests into it, and the runner executes tests from it. If the directory structure is wrong, the pipeline components cannot find each other's outputs.
