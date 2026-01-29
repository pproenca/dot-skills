---
title: Use Max Issues for Gradual Adoption
impact: MEDIUM
impactDescription: allows incremental cleanup without blocking CI
tags: ci, adoption, threshold, gradual
---

## Use Max Issues for Gradual Adoption

Use `--max-issues` to set a threshold for acceptable issues. This enables gradual adoption without blocking existing PRs while preventing new dead code.

**Incorrect (all-or-nothing blocks adoption):**

```yaml
- run: npx knip  # Fails with 500 existing issues
# Team disables Knip because it blocks all PRs
```

**Correct (threshold allows gradual cleanup):**

```yaml
- run: npx knip --max-issues 100
# Passes if issues ≤ 100, fails if new dead code added
```

**Gradual reduction strategy:**

```yaml
# Week 1: Baseline
- run: npx knip --max-issues 500

# Week 2: After cleanup sprint
- run: npx knip --max-issues 300

# Week 4: Target achieved
- run: npx knip --max-issues 0
```

**Alternative: Warn without blocking:**

```yaml
- run: npx knip --no-exit-code
# Reports issues but doesn't fail the build
```

Reference: [Knip CLI](https://knip.dev/reference/cli)
