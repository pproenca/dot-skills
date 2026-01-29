---
title: Create Immutable Releases with Unique Identifiers
impact: HIGH
impactDescription: enables reliable rollbacks, audit trails, and deployment tracking
tags: build, release, immutability, versioning
---

## Create Immutable Releases with Unique Identifiers

Every release must have a unique identifier (timestamp or incrementing number) and be immutable once created. A release is a specific build combined with specific config - any change requires a new release. Releases are append-only; you never modify an existing release.

**Incorrect (mutable releases):**

```bash
# "Release" is just the latest code on the server
ssh prod-server
cd /var/www/app

# Hotfix applied directly
vim app.py  # Quick fix for urgent bug
systemctl restart app

# Config changed in place
echo "NEW_FEATURE=true" >> .env
systemctl restart app

# What's actually running? Combination of:
# - Some git commit
# - Plus manual edits
# - Plus config accumulated over time
# - Rollback? Impossible.
```

**Correct (immutable releases):**

```bash
# Each release is a frozen snapshot
releases/
├── v100/
│   ├── build/           # From build stage
│   ├── config.json      # Frozen config snapshot
│   └── RELEASE_INFO     # Metadata
├── v101/
│   ├── build/
│   ├── config.json
│   └── RELEASE_INFO
└── v102/  # Current
    ├── build/
    ├── config.json
    └── RELEASE_INFO

# Symlink points to current release
current -> v102

# Rollback is trivial
ln -sfn releases/v101 current
systemctl restart app
```

```yaml
# RELEASE_INFO example
release_id: v102
created_at: 2024-01-15T14:30:00Z
build_sha: abc123def456
deployed_by: ci-pipeline
config_hash: sha256:789xyz
```

**Container-based releases:**

```bash
# Each image tag is an immutable release
docker images
# REPOSITORY    TAG        CREATED
# myapp         v102       2 hours ago
# myapp         v101       1 day ago
# myapp         v100       3 days ago

# Deploy specific release
kubectl set image deployment/myapp app=myapp:v102

# Rollback to previous
kubectl rollout undo deployment/myapp
# Or explicit: kubectl set image deployment/myapp app=myapp:v101
```

**Benefits:**
- Audit trail: know exactly what ran when
- Instant rollback: no rebuild required
- Reproducibility: redeploy same release to new environment
- Debugging: reproduce exact release state

Reference: [The Twelve-Factor App - Build, Release, Run](https://12factor.net/build-release-run)
