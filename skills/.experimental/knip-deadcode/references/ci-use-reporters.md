---
title: Use Appropriate Reporters for CI Output
impact: MEDIUM
impactDescription: improves issue visibility in CI logs
tags: ci, reporters, output, format
---

## Use Appropriate Reporters for CI Output

Choose the right reporter for your CI environment. Different reporters optimize for different use cases.

**Incorrect (default output hard to parse in CI):**

```yaml
- run: npx knip
# Long list, hard to find relevant issues
```

**Correct (reporter optimized for CI):**

```yaml
# GitHub Actions annotations
- run: npx knip --reporter github-actions

# Compact for quick overview
- run: npx knip --reporter compact

# JSON for programmatic processing
- run: npx knip --reporter json > knip-report.json
```

**Available reporters:**
- `symbols` (default) - Grouped by issue type with symbols
- `compact` - One line per issue
- `github-actions` - GitHub annotations on files
- `json` - Machine-readable output
- `markdown` - Documentation format
- `codeowners` - Grouped by code owners

**Combine with max-show-issues:**

```yaml
- run: npx knip --reporter compact --max-show-issues 20
```

Reference: [Knip CLI](https://knip.dev/reference/cli)
