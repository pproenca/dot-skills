---
title: Provide REPL Access for Debugging and Data Inspection
impact: MEDIUM
impactDescription: enables interactive debugging, safe data investigation
tags: admin, repl, debugging, inspection
---

## Provide REPL Access for Debugging and Data Inspection

One-off admin processes include REPL (Read-Eval-Print Loop) sessions for interactive debugging and data inspection. The REPL runs against a release, giving developers access to the app's models and configuration in production.

**Incorrect (ad-hoc REPL without proper environment):**

```bash
# SSH to production server and run Python directly
ssh prod-server
cd /var/www/app
python
>>> import app  # Wrong virtualenv, wrong config
>>> app.db.query("SELECT * FROM users")
# Uses wrong database, wrong dependencies
# No audit trail of what commands were run
```

**Correct (REPL from the release environment):**

```bash
# Django shell via kubectl - uses release's code and config
kubectl exec -it deployment/web -- python manage.py shell

# Flask shell
kubectl exec -it deployment/web -- flask shell

# Heroku - runs in isolated dyno with production config
heroku run python manage.py shell
```

**Python REPL access:

```bash
# Django shell
kubectl exec -it deployment/web -- python manage.py shell

# Flask shell
kubectl exec -it deployment/web -- flask shell

# Generic Python with app context
kubectl exec -it deployment/web -- python
>>> from app import create_app, db
>>> app = create_app()
>>> with app.app_context():
...     user = User.query.get(123)
...     print(user.email)
```

**Ruby REPL access:**

```bash
# Rails console
kubectl exec -it deployment/web -- bundle exec rails console

# IRB with app loaded
kubectl exec -it deployment/web -- bundle exec irb -r ./config/environment
```

**Node.js REPL access:**

```bash
# Node with app context
kubectl exec -it deployment/web -- node
> const db = require('./db')
> const User = require('./models/user')
> await User.findById(123)
```

**Safe REPL practices:**

```python
# Read-only investigation
>>> from app.models import Order
>>> order = Order.query.get(12345)
>>> print(order.status, order.items)

# CAREFUL with writes - use transactions
>>> from app import db
>>> with db.session.begin():
...     order.status = 'cancelled'
...     # Review change before commit
...     print(f"Will update order {order.id} to cancelled")
...     input("Press Enter to commit or Ctrl+C to abort")

# Better: use management commands for changes
# Instead of ad-hoc REPL writes
python manage.py cancel_order --order-id=12345 --dry-run
python manage.py cancel_order --order-id=12345
```

**Heroku style:**

```bash
# One-off dyno with REPL
heroku run python manage.py shell
# Runs in isolated dyno with production config
# Changes to filesystem don't affect running app
# Safe sandbox for investigation
```

**Read-only replica for safety:**

```python
# Connect REPL to read replica for investigation
# settings.py
DATABASES = {
    'default': os.environ['DATABASE_URL'],
    'readonly': os.environ.get('DATABASE_READONLY_URL', os.environ['DATABASE_URL']),
}

# In REPL
>>> from django.db import connections
>>> with connections['readonly'].cursor() as cursor:
...     cursor.execute("SELECT * FROM orders WHERE id = %s", [123])
...     print(cursor.fetchone())
# No risk of accidental writes
```

**Benefits:**
- Debug production issues with real data
- Inspect state without deploying logging
- Run one-off queries safely
- Test hypotheses interactively

Reference: [The Twelve-Factor App - Admin processes](https://12factor.net/admin-processes)
