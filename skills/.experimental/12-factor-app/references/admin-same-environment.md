---
title: Run Admin Processes Against a Release with Same Codebase and Config
impact: MEDIUM
impactDescription: prevents synchronization issues, ensures correct behavior
tags: admin, environment, release, consistency
---

## Run Admin Processes Against a Release with Same Codebase and Config

One-off admin processes must run against the same release as the app's regular processes. This means the same codebase version, the same config, and the same dependency isolation. Admin processes are NOT special - they're just short-lived processes of the same release.

**Incorrect (admin with different environment):**

```bash
# Developer laptop running migration against production
# Local code may be ahead/behind production
python manage.py migrate --database=$PROD_DATABASE_URL
# Danger: local code has unreleased migrations!

# Ops server with different code version
ssh ops-server
cd /var/www/app-v1.2.0  # Production is v1.2.3!
python manage.py fix_data
# Uses old code against new database schema

# Using different dependencies
pip install some-tool
python -c "import some_tool; some_tool.fix(db)"
# Not in requirements.txt, behavior differs from app
```

**Correct (admin from the release):**

```bash
# Run from the exact deployed release
# Kubernetes: use same image
kubectl run migration --rm -it \
  --image=myapp:v1.2.3 \          # Same image as deployment
  --restart=Never \
  --env-from=secret/app-secrets \  # Same config
  -- python manage.py migrate

# Heroku: runs against current release automatically
heroku run python manage.py migrate
# Uses current slug (release artifact) and config vars

# Docker: specify exact image
docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  myapp:v1.2.3 \
  python manage.py migrate
```

**Dependency isolation for admin:**

```bash
# Python: use bundle exec equivalent
# Correct: uses app's virtualenv
kubectl exec deployment/web -- python manage.py shell

# Ruby: bundle exec ensures app's gems
kubectl exec deployment/web -- bundle exec rails console

# Node: uses app's node_modules
kubectl exec deployment/web -- npx ts-node scripts/fix_data.ts
```

**Kubernetes Job pattern:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration-v1.2.3
spec:
  template:
    spec:
      containers:
      - name: migrate
        image: myapp:v1.2.3       # Exact release version
        command: ["python", "manage.py", "migrate"]
        envFrom:
        - configMapRef:
            name: app-config       # Same config
        - secretRef:
            name: app-secrets      # Same secrets
      restartPolicy: Never
  backoffLimit: 0
```

**Benefits:**
- Migrations match the deployed code
- Admin scripts see same database schema assumptions
- No "works locally" vs "fails in production" issues
- Clear audit trail of what ran against what

Reference: [The Twelve-Factor App - Admin processes](https://12factor.net/admin-processes)
