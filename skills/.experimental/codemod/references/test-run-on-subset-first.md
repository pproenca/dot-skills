---
title: Test on File Subset Before Full Run
impact: MEDIUM
impactDescription: catches errors 10-100x faster before full run
tags: test, subset, validation, incremental
---

## Test on File Subset Before Full Run

Run transforms on a small subset of files first. Validate results manually before applying to the entire codebase.

**Incorrect (full run immediately):**

```bash
# Run on entire codebase first time
npx codemod jssg run ./transform.ts ./src --language tsx

# 1,847 files modified
# Discover bug after 10 minutes
# Must revert everything and restart
```

**Correct (incremental validation):**

```bash
# 1. Test with fixture tests first
npx codemod jssg test ./transform.ts --language tsx

# 2. Run on single file
npx codemod jssg run ./transform.ts ./src/components/Button.tsx --language tsx
cat ./src/components/Button.tsx  # Review output

# 3. Run on small directory
npx codemod jssg run ./transform.ts ./src/components --language tsx
git diff  # Review all changes

# 4. Run on representative sample
find ./src -name "*.tsx" | head -20 | xargs dirname | sort -u | head -5
npx codemod jssg run ./transform.ts ./src/pages --language tsx

# 5. Full run after validation
npx codemod jssg run ./transform.ts ./src --language tsx
```

**Subset selection strategies:**
- Start with smallest files
- Include files with known edge cases
- Test each file type (`.ts`, `.tsx`, `.js`)
- Include files from different teams/modules

**Quick revert if needed:**

```bash
# Git makes it easy to undo
git checkout -- src/
# Or for unstaged changes
git stash
```

Reference: [JSSG CLI](https://docs.codemod.com/cli)
