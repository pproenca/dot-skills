---
title: Use Deploys Not Branches to Represent Environments
impact: HIGH
impactDescription: prevents environment-specific code paths, simplifies merging
tags: code, deployment, environments, git
---

## Use Deploys Not Branches to Represent Environments

Different environments (dev, staging, production) should be deploys of the same codebase at different commits, not separate branches with environment-specific code. The codebase is identical; only configuration differs.

**Incorrect (environment-specific branches):**

```bash
# Branches diverge with environment-specific changes
git branch -a
# * main
#   staging       # Has staging-specific hacks
#   production    # Has production-specific hacks

# Merging becomes a nightmare
git checkout production
git merge main
# CONFLICT: config/database.js has production-specific settings

# Code contains environment conditionals
if (process.env.NODE_ENV === 'production') {
  // Production-only code path
  enableCaching();
} else if (process.env.NODE_ENV === 'staging') {
  // Staging-only code path
  enableDebugLogging();
}
```

**Correct (single codebase, multiple deploys):**

```bash
# One main branch, tags mark releases
git log --oneline --decorate
# a1b2c3d (HEAD -> main) Latest feature
# d4e5f6g (tag: v1.2.3) Production release
# h7i8j9k (tag: v1.2.2) Previous release

# Deploy specific versions to environments
# Production: v1.2.3
# Staging: main (latest)
# Dev: local checkout
```

```javascript
// Code is identical across all environments
// Behavior varies only through configuration
const cacheEnabled = process.env.CACHE_ENABLED === 'true';
const logLevel = process.env.LOG_LEVEL || 'info';

if (cacheEnabled) {
  enableCaching();
}
logger.setLevel(logLevel);
```

**Benefits:**
- No merge conflicts between environment branches
- Every commit can be deployed to any environment
- Staging truly tests what will go to production

Reference: [The Twelve-Factor App - Codebase](https://12factor.net/codebase)
