---
title: Avoid Broad Ignore Patterns
impact: CRITICAL
impactDescription: prevents hiding legitimate dead code issues
tags: config, ignore, patterns, false-negatives
---

## Avoid Broad Ignore Patterns

Broad ignore patterns hide legitimate issues along with false positives. Use targeted ignores with specific options instead.

**Incorrect (hides all issues in generated files):**

```json
{
  "ignore": ["src/generated/**"]
}
```

Hides unused files, exports, dependencies, and all other issues in generated files.

**Correct (only unused files hidden, other issues still reported):**

```json
{
  "ignoreFiles": ["src/generated/**"]
}
```

Only hides unused file reports; unused exports and dependencies in generated files are still caught.

**Alternative (suppress specific issue type per pattern):**

```json
{
  "ignoreIssues": {
    "exports": ["src/generated/**/*.ts"]
  }
}
```

**Available targeted ignore options:**
- `ignoreDependencies`: Suppress unused dependency reports
- `ignoreFiles`: Exclude from unused files detection only
- `ignoreBinaries`: Exclude missing binaries
- `ignoreMembers`: Exclude class/enum members
- `ignoreUnresolved`: Exclude unresolved imports
- `ignoreIssues`: Suppress specific issue types per pattern

Reference: [Knip Configuration](https://knip.dev/reference/configuration)
