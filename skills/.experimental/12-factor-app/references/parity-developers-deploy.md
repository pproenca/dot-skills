---
title: Involve Developers in Deployment to Minimize Personnel Gap
impact: MEDIUM
impactDescription: faster issue resolution, better understanding of production behavior
tags: parity, devops, deployment, ownership
---

## Involve Developers in Deployment to Minimize Personnel Gap

In a twelve-factor workflow, developers who write code are closely involved in deploying it and watching its behavior in production. The traditional wall between "dev" and "ops" creates a personnel gap that slows feedback and obscures problems.

**Incorrect (separated dev and ops):**

```text
Traditional Workflow:
1. Developer writes code
2. Developer marks ticket "ready for deploy"
3. Wait for deployment window (next Tuesday)
4. Ops team deploys during maintenance window
5. Ops notices errors in monitoring
6. Ops creates ticket for dev team
7. Dev team investigates (no production access)
8. Dev asks ops to run queries
9. Back and forth for days
10. Fix deployed next week
```

**Correct (developers deploy and observe):**

```text
Twelve-Factor Workflow:
1. Developer writes code
2. Developer pushes to main
3. CI/CD automatically deploys to staging
4. Developer verifies staging
5. Developer promotes to production (one-click)
6. Developer watches metrics and logs
7. Developer sees error spike immediately
8. Developer investigates with production access
9. Developer deploys fix within hours
```

**Enable developer deployment:**

```yaml
# Deployment should be simple enough for any developer
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm test
      - run: npm run deploy
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}

# Anyone can trigger production deploy via merge to main
# No special ops knowledge required
```

**Developer access to production:**

```bash
# Developers can view logs
kubectl logs -f deployment/web

# Developers can access REPL
kubectl exec -it deployment/web -- python manage.py shell

# Developers can run migrations
kubectl exec -it deployment/web -- python manage.py migrate

# Developers can view metrics
# Link to Grafana/Datadog dashboard in README

# Developers can roll back
kubectl rollout undo deployment/web
```

**Self-service deployment:**

```bash
# Developer can deploy without ops involvement
git push origin main  # Triggers CI/CD

# Or manual promotion
./scripts/promote-to-production.sh

# Emergency rollback
./scripts/rollback-production.sh

# All actions logged and auditable
# No gatekeeping, just guardrails
```

**Benefits:**
- Faster feedback loops
- Developers understand production behavior
- Issues resolved quickly by people with context
- Shared responsibility improves quality

Reference: [The Twelve-Factor App - Dev/prod parity](https://12factor.net/dev-prod-parity)
