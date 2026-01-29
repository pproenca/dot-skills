---
title: Trace Export Usage Before Removal
impact: MEDIUM-HIGH
impactDescription: prevents removing actually-used exports
tags: exports, trace, investigation, safety
---

## Trace Export Usage Before Removal

Use `--trace-export` to investigate where an export is used before removing it. This catches usage patterns Knip may not detect.

**Incorrect (removing without investigation):**

```bash
knip
# Reports: formatDate is unused

# User removes formatDate
# Breaks: dynamic import that uses formatDate
```

**Correct (trace before removal):**

```bash
knip --trace-export formatDate
```

Output shows:
```text
Tracing export: formatDate
  - Not found in static imports
  - Not found in re-exports
  - Consider checking dynamic imports
```

**Trace file usage:**

```bash
knip --trace-file src/utils/date.ts
```

Shows which files import from date.ts.

**Trace dependency usage:**

```bash
knip --trace-dependency lodash
```

Shows where lodash is imported.

**When tracing is essential:**
- Large codebases with dynamic imports
- Exports used in config files
- Exports consumed by external packages

Reference: [Knip CLI](https://knip.dev/reference/cli)
