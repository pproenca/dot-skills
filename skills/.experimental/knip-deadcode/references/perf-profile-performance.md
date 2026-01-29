---
title: Profile Performance for Slow Analysis
impact: LOW-MEDIUM
impactDescription: identifies bottlenecks in analysis pipeline
tags: perf, profiling, debug, optimization
---

## Profile Performance for Slow Analysis

Use `--performance` to identify which operations are slow. This helps optimize configuration for faster analysis.

**Incorrect (slow analysis without investigation):**

```bash
knip  # Takes 5 minutes, unclear why
```

**Correct (profile to find bottlenecks):**

```bash
knip --performance
```

Output shows:
```text
Performance:
  findWorkspaces: 50ms
  resolveModules: 2500ms  <- Bottleneck
  analyzeExports: 1200ms
  resolveTypes: 800ms
```

**Profile specific function:**

```bash
knip --performance-fn resolveModules
```

**Memory profiling:**

```bash
knip --memory
# Shows peak memory usage

knip --memory-realtime
# Streams memory usage during execution
```

**Common causes of slow analysis:**
- Large node_modules with `--include-libs`
- Too many entry patterns matching files
- Missing cache (`--cache` not enabled)
- Analyzing generated files

Reference: [Knip CLI](https://knip.dev/reference/cli)
