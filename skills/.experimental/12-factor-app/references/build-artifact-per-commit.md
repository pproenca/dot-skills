---
title: Generate One Build Artifact Per Commit Deploy Same Artifact Everywhere
impact: MEDIUM-HIGH
impactDescription: guarantees staging tests what production runs, eliminates build inconsistency
tags: build, artifacts, ci-cd, consistency
---

## Generate One Build Artifact Per Commit Deploy Same Artifact Everywhere

Build the application once per commit, producing a single artifact that is deployed to all environments. Never rebuild for staging vs production - the artifact is identical, only configuration differs.

**Incorrect (rebuild per environment):**

```yaml
# CI pipeline that rebuilds for each environment
deploy-staging:
  script:
    - npm install
    - npm run build  # Build #1 for staging
    - deploy-to-staging

deploy-production:
  script:
    - npm install
    - npm run build  # Build #2 for production
    - deploy-to-production
# Different npm install = potentially different packages
# Different build = potentially different output
# "Works in staging" doesn't guarantee production works
```

**Correct (build once, deploy anywhere):**

```yaml
# CI pipeline with single build
stages:
  - build
  - deploy-staging
  - deploy-production

build:
  stage: build
  script:
    - npm ci  # Deterministic install from lockfile
    - npm run build
    - docker build -t myapp:$CI_COMMIT_SHA .
    - docker push registry/myapp:$CI_COMMIT_SHA
  artifacts:
    # Build artifact available to later stages
    paths:
      - dist/

deploy-staging:
  stage: deploy-staging
  script:
    # Deploy the SAME artifact built above
    - kubectl set image deployment/myapp app=registry/myapp:$CI_COMMIT_SHA
    # Staging uses staging config
  environment: staging

deploy-production:
  stage: deploy-production
  script:
    # Deploy the EXACT SAME artifact
    - kubectl set image deployment/myapp app=registry/myapp:$CI_COMMIT_SHA
    # Production uses production config
  environment: production
  when: manual  # Requires approval
```

**Container tagging strategy:**

```bash
# Tag with commit SHA (immutable)
docker build -t myapp:abc123def .
docker push registry/myapp:abc123def

# Optionally add semantic tags to same image
docker tag myapp:abc123def myapp:v1.2.3
docker tag myapp:abc123def myapp:latest
docker push registry/myapp:v1.2.3
docker push registry/myapp:latest

# All tags point to identical image
# Staging deployed with :abc123def
# Production deployed with same :abc123def
```

**Benefits:**
- What passed tests in staging is exactly what runs in production
- No "but the production build is different" debugging
- Artifact can be promoted without rebuilding
- Audit trail: commit SHA → artifact → all deployments

Reference: [The Twelve-Factor App - Build, Release, Run](https://12factor.net/build-release-run)
