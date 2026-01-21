---
title: Batch Operations Instead of Loops
impact: LOW-MEDIUM
impactDescription: single command vs N process spawns
tags: perf, batch, loops, find, xargs
---

## Batch Operations Instead of Loops

Looping over files and running a command for each spawns N processes. Batch commands like `find -exec +`, `xargs`, or glob expansion run one process for many files.

**Incorrect (one command per file):**

```bash
#!/bin/bash
# Spawns grep N times
for file in *.log; do
  grep "error" "$file"
done

# Spawns chmod N times
for file in $(find . -name "*.sh"); do
  chmod +x "$file"
done

# Spawns rm N times
for file in /tmp/cache/*; do
  rm "$file"
done
```

**Correct (batch operations):**

```bash
#!/bin/bash
# One grep with multiple files
grep "error" *.log

# find -exec with + (batches arguments)
find . -name "*.sh" -exec chmod +x {} +

# rm with glob (one invocation)
rm /tmp/cache/*

# xargs for complex batching
find . -name "*.log" -print0 | xargs -0 grep "error"
```

**find -exec + vs \;:**

```bash
#!/bin/bash
# \; runs command once per file (slow)
find . -name "*.txt" -exec grep "pattern" {} \;
# Equivalent to: grep pattern file1; grep pattern file2; ...

# + batches files into single command (fast)
find . -name "*.txt" -exec grep "pattern" {} +
# Equivalent to: grep pattern file1 file2 file3 ...

# Handles ARG_MAX automatically - splits if too many
```

**xargs for complex batching:**

```bash
#!/bin/bash
# Basic xargs
find . -name "*.log" | xargs rm

# Handle spaces and special chars with -0
find . -name "*.log" -print0 | xargs -0 rm

# Limit batch size
find . -name "*.log" -print0 | xargs -0 -n 100 rm

# Parallel execution
find . -name "*.log" -print0 | xargs -0 -P 4 -n 10 compress

# With placeholder
find . -name "*.txt" -print0 | xargs -0 -I {} cp {} /backup/

# Run if no input (--no-run-if-empty)
find . -name "*.bak" -print0 | xargs -0 --no-run-if-empty rm
```

**When loops are necessary:**

```bash
#!/bin/bash
# When you need shell logic per file
for file in *.txt; do
  if [[ -s "$file" ]]; then
    # Complex shell logic
    base="${file%.txt}"
    mv "$file" "${base}_$(date +%Y%m%d).txt"
  fi
done

# When you need variables from iteration
total=0
for file in *.csv; do
  count=$(wc -l < "$file")
  ((total += count))
done
echo "Total lines: $total"
```

**Parallel batch operations:**

```bash
#!/bin/bash
# GNU parallel for complex parallel batching
find . -name "*.jpg" | parallel convert {} -resize 50% {.}_thumb.jpg

# xargs parallel
find . -name "*.gz" -print0 | xargs -0 -P $(nproc) gunzip

# Background jobs (manual parallelism)
for file in *.dat; do
  process "$file" &
done
wait  # Wait for all background jobs
```

**Safe batch operations:**

```bash
#!/bin/bash
# Always handle special filenames
# Use -print0 and -0 for null-separated

# Dangerous (spaces, newlines break this)
find . -name "*.txt" | xargs rm

# Safe
find . -name "*.txt" -print0 | xargs -0 rm

# Or use find -exec directly
find . -name "*.txt" -exec rm {} +
```

Reference: [GNU Findutils Manual](https://www.gnu.org/software/findutils/manual/html_mono/find.html)
