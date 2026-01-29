---
title: Run Admin Tasks as One-Off Processes Not Special Scripts
impact: MEDIUM
impactDescription: ensures consistency, enables auditability, prevents configuration drift
tags: admin, processes, one-off, maintenance
---

## Run Admin Tasks as One-Off Processes Not Special Scripts

Administrative tasks (database migrations, REPL sessions, data fixes) should run as one-off processes in an identical environment to the app's regular processes. They use the same codebase, config, and dependency isolation.

**Incorrect (separate admin scripts):**

```bash
# Admin scripts outside the main codebase
/scripts/migrate.sh  # Different environment, different config
/scripts/fix_data.py  # May have different dependencies

# SSH to production server and run manually
ssh prod-server
cd /var/www/app
source /different/virtualenv/bin/activate  # Different env
python scripts/fix_data.py  # Different config source
# What config did it use? What version of code?
```

**Correct (one-off processes from release):**

```python
# Admin commands are part of the app
# Django
python manage.py migrate
python manage.py shell
python manage.py fix_bad_records  # Custom command

# Flask with Click
flask db upgrade
flask shell
flask fix-bad-records

# These run with the SAME:
# - Codebase version
# - Dependencies
# - Configuration
# - Isolation
```

**Running admin processes in production:**

```bash
# Heroku
heroku run python manage.py migrate
heroku run python manage.py shell
heroku run python scripts/fix_data.py

# Kubernetes
kubectl exec -it deployment/web -- python manage.py migrate
kubectl exec -it deployment/web -- python manage.py shell

# Or as a Job
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: migration
spec:
  template:
    spec:
      containers:
      - name: migrate
        image: myapp:v1.2.3  # Same image as web
        command: ["python", "manage.py", "migrate"]
        envFrom:
        - secretRef:
            name: app-secrets
      restartPolicy: Never
EOF

# Docker
docker run --rm -e DATABASE_URL="..." myapp:v1.2.3 python manage.py migrate
```

**Admin commands live in the codebase:**

```python
# myapp/management/commands/fix_bad_records.py
from django.core.management.base import BaseCommand

class Command(BaseCommand):
    help = 'Fix records with invalid status'

    def add_arguments(self, parser):
        parser.add_argument('--dry-run', action='store_true')

    def handle(self, *args, **options):
        records = Record.objects.filter(status='invalid')
        self.stdout.write(f'Found {records.count()} invalid records')

        if not options['dry_run']:
            records.update(status='pending')
            self.stdout.write(self.style.SUCCESS('Fixed!'))
```

**Benefits:**
- Same code, same config, same dependencies
- Auditable: which release did the migration run against?
- Reproducible: can run same command in any environment
- Version controlled: admin scripts are part of the app

Reference: [The Twelve-Factor App - Admin processes](https://12factor.net/admin-processes)
