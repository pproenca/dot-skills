---
title: Maintain One Codebase Per Application in Version Control
impact: CRITICAL
impactDescription: enables consistent deployments, prevents configuration drift
tags: code, version-control, git, deployment
---

## Maintain One Codebase Per Application in Version Control

Every twelve-factor application has exactly one codebase tracked in version control. This single source of truth ensures all deploys (dev, staging, production) originate from the same code, eliminating "works on my machine" issues and enabling reliable rollbacks.

**Incorrect (multiple codebases or no version control):**

```bash
# Multiple separate directories for each environment
/app-dev/
/app-staging/
/app-production/
# Or copying code between machines via FTP/SCP
scp -r ./myapp user@prod:/var/www/
# No version history, no rollback capability
```

**Correct (single codebase with version control):**

```bash
# One repository, many deploys
git clone https://github.com/company/myapp.git

# Different environments use the same codebase at different commits
# Production: deployed from tag v1.2.3
# Staging: deployed from main branch
# Development: local checkout of main branch

git log --oneline
# a1b2c3d (HEAD -> main, tag: v1.2.3) Fix payment processing
# d4e5f6g Add user authentication
# h7i8j9k Initial commit
```

**Benefits:**
- Complete history of all changes enables bisecting bugs
- Any developer can reproduce any deploy
- Rollbacks are trivial: just redeploy an earlier commit
- Code reviews and CI/CD operate on the single source of truth

Reference: [The Twelve-Factor App - Codebase](https://12factor.net/codebase)
