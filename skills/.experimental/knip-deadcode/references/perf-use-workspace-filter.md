---
title: Filter Workspaces for Faster Monorepo Analysis
impact: LOW-MEDIUM
impactDescription: analyzes only changed packages
tags: perf, workspace, monorepo, filter
---

## Filter Workspaces for Faster Monorepo Analysis

Use `--workspace` to analyze specific packages in a monorepo. This dramatically speeds up analysis when working on a single package.

**Incorrect (analyzing entire monorepo for single package change):**

```bash
knip  # Analyzes all 50 packages, takes 5 minutes
```

**Correct (analyze affected workspace only):**

```bash
knip --workspace packages/auth
# Analyzes only the auth package, takes 10 seconds
```

**Multiple workspaces:**

```bash
knip --workspace packages/auth --workspace packages/api
# or
knip -W packages/auth -W packages/api
```

**Glob patterns:**

```bash
knip --workspace "packages/ui-*"
# Analyzes all ui- prefixed packages
```

**CI optimization for changed packages:**

```yaml
- name: Get changed packages
  id: changed
  run: echo "packages=$(git diff --name-only HEAD~1 | grep '^packages/' | cut -d'/' -f2 | uniq | tr '\n' ',')" >> $GITHUB_OUTPUT

- name: Run Knip on changed packages
  run: |
    for pkg in $(echo "${{ steps.changed.outputs.packages }}" | tr ',' '\n'); do
      npx knip --workspace "packages/$pkg"
    done
```

Reference: [Knip CLI](https://knip.dev/reference/cli)
