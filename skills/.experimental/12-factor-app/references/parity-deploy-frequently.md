---
title: Deploy Frequently to Minimize the Time Gap
impact: MEDIUM
impactDescription: reduces risk per deploy, accelerates feedback loops
tags: parity, deployment, continuous-deployment, time-gap
---

## Deploy Frequently to Minimize the Time Gap

The twelve-factor developer makes the time gap small: code should be deployed within hours or minutes of being written, not weeks or months. Frequent small deploys are less risky than infrequent large deploys.

**Incorrect (infrequent deploys):**

```text
Development Timeline:
Week 1: Feature A developed
Week 2: Feature B developed
Week 3: Feature C developed
Week 4: Code review for all features
Week 5: QA testing
Week 6: Staging deployment
Week 7: Production deployment

Problems:
- 6 weeks of changes in one deploy
- If something breaks, hard to identify which feature
- Developers don't remember the context
- Rollback means losing 3 features
- Large merge conflicts
```

**Correct (frequent deploys):**

```text
Continuous Deployment Timeline:
Monday 9am: Feature A merged → deployed to staging → promoted to production
Monday 2pm: Bug fix merged → deployed → production
Tuesday 11am: Feature B merged → deployed → production
Wednesday 9am: Feature C merged → deployed → production

Benefits:
- Each deploy is small and understandable
- If something breaks, obvious which commit caused it
- Context is fresh in developer's mind
- Rollback loses only one small change
- No merge conflicts
```

**CI/CD pipeline for frequent deploys:**

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm test

  deploy-staging:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - run: deploy-to-staging

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production  # Requires approval
    steps:
      - run: deploy-to-production
```

**Feature flags for incomplete features:**

```python
# Deploy incomplete feature behind flag
from feature_flags import is_enabled

@app.route('/new-dashboard')
def new_dashboard():
    if is_enabled('new_dashboard', current_user):
        return render_template('new_dashboard.html')
    return redirect('/dashboard')

# Can deploy partial implementation daily
# Enable for small percentage to test
# Roll out gradually or instant when ready
```

**Small, focused commits:**

```bash
# Bad: large commit with many changes
git commit -m "Add user dashboard, fix login bug, update deps"

# Good: small, focused commits
git commit -m "Add user dashboard route"
git commit -m "Add dashboard template"
git commit -m "Fix login redirect bug"
git commit -m "Update security dependencies"
# Each can be deployed (and rolled back) independently
```

**Benefits:**
- Lower risk per deployment
- Faster feedback from production
- Easier debugging when issues arise
- Continuous improvement mindset

Reference: [The Twelve-Factor App - Dev/prod parity](https://12factor.net/dev-prod-parity)
