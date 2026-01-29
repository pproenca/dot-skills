---
title: Never Modify Code at Runtime - Changes Require New Release
impact: HIGH
impactDescription: prevents configuration drift, ensures reproducibility
tags: build, immutability, runtime, deployment
---

## Never Modify Code at Runtime - Changes Require New Release

Code changes cannot be made at runtime because there is no way to propagate those changes back to the build stage. Any fix, feature, or update requires going through the full build-release-run pipeline. This ensures every change is tracked, tested, and reproducible.

**Incorrect (runtime modifications):**

```bash
# Production server
ssh prod-server
cd /var/www/app

# "Quick fix" - edit code directly
vim app/views.py
# Add a try/except to handle edge case

# "Quick config" - change settings file
vim config/settings.py
# TIMEOUT = 30  # was 10

# "Quick update" - pull specific file
git checkout origin/main -- app/utils.py

systemctl restart app
# These changes exist only on this server
# Not in git, not reproducible, no tests ran
```

**Correct (all changes via build pipeline):**

```bash
# 1. Make change in development
git checkout -b fix/handle-edge-case
vim app/views.py
git add -A && git commit -m "Handle edge case in view"

# 2. Push triggers CI pipeline
git push origin fix/handle-edge-case
# CI runs tests, linting, security scans

# 3. Merge after review
# PR merged to main

# 4. Build stage creates new artifact
# Build: myapp-abc123.tar.gz

# 5. Release stage creates new release
# Release: v103

# 6. Run stage deploys new release
kubectl set image deployment/myapp app=myapp:v103

# Change is tracked, tested, reproducible
git log --oneline
# abc123 Handle edge case in view
```

**Emergency hotfix process:**

```bash
# Even urgent fixes go through the pipeline
# Just with an expedited process

# 1. Branch from production tag
git checkout v102 -b hotfix/urgent-fix
vim app/views.py
git commit -m "Hotfix: handle null case"

# 2. Emergency CI run (maybe skip some slow tests)
git push origin hotfix/urgent-fix
# CI: lint, unit tests, security (skip e2e)

# 3. Fast-track merge and deploy
# Release: v103-hotfix
kubectl set image deployment/myapp app=myapp:v103-hotfix

# 4. Cherry-pick to main after incident
git checkout main
git cherry-pick abc123
```

**Benefits:**
- Every change is in version control
- All changes are tested before deployment
- Any server can be rebuilt from scratch
- Rollback is always possible

Reference: [The Twelve-Factor App - Build, Release, Run](https://12factor.net/build-release-run)
