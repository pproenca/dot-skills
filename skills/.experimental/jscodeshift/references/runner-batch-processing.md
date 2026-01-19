---
title: Process Large Codebases in Batches
impact: LOW-MEDIUM
impactDescription: prevents memory exhaustion on large codebases
tags: runner, batch, memory, large-codebases
---

## Process Large Codebases in Batches

Very large codebases can exhaust memory when jscodeshift tracks all files. Process in batches for better memory management.

**Incorrect (process entire monorepo at once):**

```bash
# May run out of memory on 10k+ file codebases
jscodeshift -t transform.js packages/

# Node.js heap fills up tracking all file results
```

**Correct (batch by package or directory):**

```bash
# Process package by package
for pkg in packages/*; do
  echo "Processing $pkg"
  jscodeshift -t transform.js "$pkg/src"
done

# Or use find with xargs for parallelism
find packages -name "src" -type d | xargs -P 4 -I {} \
  jscodeshift -t transform.js {}
```

**Alternative (split by file count):**

```bash
# Get all files, process in batches of 1000
find src -name "*.ts" -o -name "*.tsx" | \
  split -l 1000 - /tmp/batch_

for batch in /tmp/batch_*; do
  jscodeshift -t transform.js $(cat "$batch" | tr '\n' ' ')
  rm "$batch"
done
```

**Memory tuning:**

```bash
# Increase Node.js heap size for large batches
NODE_OPTIONS="--max-old-space-size=8192" \
  jscodeshift -t transform.js src/

# Reduce worker count to lower memory per batch
jscodeshift --cpus=2 -t transform.js src/
```

**Note:** Monitor memory usage with `--verbose` flag and adjust batch size accordingly.

Reference: [jscodeshift - Running on Large Codebases](https://github.com/facebook/jscodeshift)
