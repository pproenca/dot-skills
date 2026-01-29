---
title: Never Use Sticky Sessions - Store Session Data in Backing Services
impact: HIGH
impactDescription: enables load balancer flexibility, prevents single-point-of-failure
tags: proc, sessions, sticky-sessions, redis
---

## Never Use Sticky Sessions - Store Session Data in Backing Services

Sticky sessions (affinity) route users to the same server instance, creating state in the process. This is a violation of twelve-factor. Session state should be stored in a backing service with time-expiration, like Redis or Memcached, so any process can handle any request.

**Incorrect (sticky sessions):**

```python
# Flask with default session (stored in signed cookie or process memory)
from flask import Flask, session

app = Flask(__name__)
app.secret_key = 'secret'

@app.route('/login')
def login():
    session['user_id'] = get_user_id()
    session['cart'] = []  # Shopping cart in session
    # Session data is in process memory or oversized cookie
    # Load balancer must route this user to same server
```

```nginx
# nginx sticky session config (the problem)
upstream backend {
    ip_hash;  # Routes based on client IP - creates affinity
    server backend1:8000;
    server backend2:8000;
}
# If backend1 goes down, all its users lose their sessions
```

**Correct (external session store):**

```python
from flask import Flask
from flask_session import Session
import redis

app = Flask(__name__)
app.config['SESSION_TYPE'] = 'redis'
app.config['SESSION_REDIS'] = redis.from_url(os.environ['REDIS_URL'])
app.config['SESSION_PERMANENT'] = False
Session(app)

@app.route('/login')
def login():
    session['user_id'] = get_user_id()
    session['cart'] = []
    # Session stored in Redis with automatic expiration
    # Any backend server can read/write this session
```

```nginx
# nginx without sticky sessions
upstream backend {
    # Round-robin (default) - no affinity needed
    server backend1:8000;
    server backend2:8000;
    server backend3:8000;
}
# Any server can handle any request
# Server failure doesn't lose sessions
```

**Session storage options:**

```python
# Redis - fast, supports expiration
SESSION_REDIS = redis.from_url(os.environ['REDIS_URL'])

# PostgreSQL - if you need transactional guarantees
SESSION_SQLALCHEMY = SQLAlchemy(app)

# Memcached - simple, volatile (acceptable for sessions)
SESSION_MEMCACHED = pylibmc.Client([os.environ['MEMCACHED_URL']])
```

**Benefits:**
- Load balancer can route any request anywhere
- Servers can be added/removed without session impact
- Server crash doesn't log out users
- Scaling is linear - just add servers

Reference: [The Twelve-Factor App - Processes](https://12factor.net/processes)
