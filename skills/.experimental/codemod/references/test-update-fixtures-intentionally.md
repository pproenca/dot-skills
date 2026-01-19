---
title: Update Test Fixtures Intentionally
impact: MEDIUM
impactDescription: prevents accidental regressions from auto-updates
tags: test, fixtures, update, review
---

## Update Test Fixtures Intentionally

Use the `-u` flag to update expected files, but always review changes before committing. Auto-updated fixtures can hide regressions.

**Incorrect (blindly updating):**

```bash
# Tests fail after transform change
npx codemod jssg test ./transform.ts
# 3 tests failed

# Blindly accept all changes
npx codemod jssg test ./transform.ts -u
# 3 fixtures updated

git add -A && git commit -m "fix tests"
# Might have committed regressions!
```

**Correct (review before committing):**

```bash
# Tests fail after transform change
npx codemod jssg test ./transform.ts
# ✗ basic-transform: output differs from expected

# Update fixtures
npx codemod jssg test ./transform.ts -u
# Updated: tests/basic-transform/expected.tsx

# Review what changed
git diff tests/

# Verify changes are intentional
# - Is the new output correct?
# - Does it match the intended behavior change?
# - Are there unexpected side effects?

# Only then commit
git add tests/ && git commit -m "Update fixtures for new format"
```

**Fixture review checklist:**
- [ ] New output is semantically correct
- [ ] Formatting matches project style
- [ ] No unintended side effects
- [ ] Comments are preserved appropriately
- [ ] Edge cases still handled correctly

**CI protection:**

```yaml
# Fail CI if fixtures need updating
- run: npx codemod jssg test ./transform.ts
# Don't use -u in CI - force explicit updates
```

Reference: [JSSG Testing](https://docs.codemod.com/jssg/testing)
