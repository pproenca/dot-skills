---
title: Strictly Separate Build, Release, and Run Stages
impact: HIGH
impactDescription: enables rollbacks, prevents runtime modifications, improves reliability
tags: build, release, deployment, ci-cd
---

## Strictly Separate Build, Release, and Run Stages

A twelve-factor app has three distinct stages: build (compile code into executable), release (combine build with config), and run (launch processes). These stages are strictly separated - you cannot modify code at runtime, and each release is immutable.

**Incorrect (blurred stages):**

```bash
# SSH into production server
ssh prod-server

# Pull latest code directly on production
cd /var/www/app
git pull origin main

# Install dependencies on production
pip install -r requirements.txt

# Modify config file on server
vim config.py

# Restart
systemctl restart app

# No build artifact, no release tracking
# "What version is running?" - who knows
```

**Correct (separate stages):**

```bash
# BUILD STAGE (CI server)
# Triggered by git push, produces an artifact
git checkout $COMMIT_SHA
pip install -r requirements.txt
python -m compileall .
tar -czf build-${COMMIT_SHA}.tar.gz .
aws s3 cp build-${COMMIT_SHA}.tar.gz s3://builds/

# RELEASE STAGE (deployment)
# Combines build artifact with environment config
# Creates immutable release v42
release_id="v42"
aws s3 cp s3://builds/build-${COMMIT_SHA}.tar.gz ./
# Config comes from environment, not bundled

# RUN STAGE (execution environment)
# Starts processes from the release
DATABASE_URL="..." python app.py
# Code cannot be modified here
```

**Using containers (clear separation):**

```dockerfile
# BUILD STAGE
FROM python:3.11 AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt
COPY . .
RUN python -m compileall .

# RELEASE: image tagged with commit SHA
# docker build -t myapp:abc123 .
# docker push registry/myapp:abc123

# RUN: container started with config
# docker run -e DATABASE_URL="..." registry/myapp:abc123
```

**Benefits:**
- Build once, deploy many times (same artifact to staging and production)
- Releases are numbered and trackable
- Rollback = redeploy previous release
- No "it worked when I deployed it manually" issues

Reference: [The Twelve-Factor App - Build, Release, Run](https://12factor.net/build-release-run)
