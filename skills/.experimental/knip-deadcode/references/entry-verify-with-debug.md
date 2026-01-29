---
title: Verify Entry Points with Debug Mode
impact: CRITICAL
impactDescription: identifies missing entries before false positive investigation
tags: entry, debug, troubleshooting, verification
---

## Verify Entry Points with Debug Mode

Use `--debug` to verify which entry files Knip discovered. Missing entries in debug output explain false positive unused file reports.

**Incorrect (investigating false positives without verifying entries):**

```bash
# User sees unused files, adds ignore patterns
knip
# Result: Real issues hidden, problem not solved
```

**Correct (verify entries first):**

```bash
knip --debug 2>&1 | grep "entry"
```

Output shows discovered entries:
```text
[DEBUG] Included entry files: src/index.ts, src/cli.ts
[DEBUG] Plugin entry files: pages/index.tsx, pages/api/auth.ts
```

**If entries are missing, add them:**

```json
{
  "entry": [
    "src/index.ts",
    "src/cli.ts",
    "src/missing-entry.ts"
  ]
}
```

**Check workspace configurations:**

```bash
knip --debug 2>&1 | grep "workspace"
```

Reference: [Knip CLI - Debug](https://knip.dev/reference/cli)
