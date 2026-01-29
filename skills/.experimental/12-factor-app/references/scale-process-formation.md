---
title: Define Process Formation as Declarative Configuration
impact: MEDIUM-HIGH
impactDescription: enables reproducible deployments, infrastructure as code
tags: scale, formation, infrastructure, declarative
---

## Define Process Formation as Declarative Configuration

The process formation (array of process types and their replica counts) should be declared in configuration, not managed manually. This enables reproducible deployments and infrastructure-as-code practices.

**Incorrect (manual process management):**

```bash
# SSH to each server and start processes
ssh server1 "cd /app && gunicorn app:app &"
ssh server2 "cd /app && celery worker &"
ssh server3 "cd /app && celery worker &"

# No record of what's running where
# Scaling requires manual intervention
# Hard to recreate after disaster
```

**Correct (declarative process formation):**

```yaml
# Procfile - defines process types
web: gunicorn app:application --workers $WEB_CONCURRENCY
worker: celery -A tasks worker --concurrency $CELERY_CONCURRENCY
scheduler: celery -A tasks beat
```

```yaml
# kubernetes/deployment.yaml - defines formation
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 5  # Declarative replica count
  template:
    spec:
      containers:
      - name: web
        command: ["gunicorn", "app:application"]
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: worker
spec:
  replicas: 10
  template:
    spec:
      containers:
      - name: worker
        command: ["celery", "-A", "tasks", "worker"]
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scheduler
spec:
  replicas: 1  # Only one scheduler
  template:
    spec:
      containers:
      - name: scheduler
        command: ["celery", "-A", "tasks", "beat"]
```

**Environment-specific formation:**

```yaml
# formation.yaml (custom config)
production:
  web: 10
  worker: 20
  scheduler: 1

staging:
  web: 2
  worker: 2
  scheduler: 1

development:
  web: 1
  worker: 1
  scheduler: 1
```

```bash
# Apply formation declaratively
kubectl apply -f kubernetes/
# Or
heroku ps:scale $(cat formation.yaml | yq '.production | to_entries | .[] | .key + "=" + (.value | tostring)' | tr '\n' ' ')
```

**Benefits:**
- Version-controlled infrastructure
- Reproducible across environments
- Easy to review changes
- Disaster recovery: just reapply manifests

Reference: [The Twelve-Factor App - Concurrency](https://12factor.net/concurrency)
