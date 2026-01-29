---
title: Update Package Manager After Dependency Fix
impact: MEDIUM
impactDescription: ensures lock file and node_modules stay in sync
tags: fix, dependencies, npm, lockfile
---

## Update Package Manager After Dependency Fix

After Knip removes dependencies from package.json, run your package manager to update the lock file and node_modules.

**Incorrect (lock file out of sync):**

```bash
knip --fix-type dependencies
# package.json updated, but package-lock.json still has old deps
```

**Correct (update lock file after fix):**

```bash
knip --fix-type dependencies
npm install  # Updates package-lock.json and node_modules
```

**For different package managers:**

```bash
# npm
npm install

# pnpm
pnpm install

# yarn
yarn install
```

**Complete workflow:**

```bash
# 1. Fix dependencies
knip --fix-type dependencies

# 2. Update lock file
npm install

# 3. Verify project still works
npm test

# 4. Commit both files
git add package.json package-lock.json
git commit -m "Remove unused dependencies"
```

Reference: [Auto-fix](https://knip.dev/features/auto-fix)
