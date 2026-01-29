---
title: Minimize Startup Time to Enable Rapid Scaling and Recovery
impact: HIGH
impactDescription: enables autoscaling responsiveness, faster deployments, quicker crash recovery
tags: disp, startup, performance, scaling
---

## Minimize Startup Time to Enable Rapid Scaling and Recovery

Processes should start in seconds, not minutes. Fast startup enables rapid scaling in response to traffic spikes and quick recovery from process crashes. Slow startup creates vulnerability windows and delays deployments.

**Incorrect (slow startup):**

```python
# Startup does too much
def create_app():
    app = Flask(__name__)

    # Load entire ML model into memory - 30 seconds
    app.model = load_large_model('model.pkl')

    # Pre-warm caches with ALL data - 45 seconds
    app.cache = {}
    for item in fetch_all_items():  # 100k items
        app.cache[item.id] = item

    # Verify all external services - 15 seconds
    verify_database_connection()
    verify_redis_connection()
    verify_s3_connection()
    verify_email_service()

    return app
# Total: 90 seconds before handling first request
# Autoscaler adds capacity too slowly during traffic spike
```

**Correct (fast startup):**

```python
def create_app():
    app = Flask(__name__)

    # Lazy-load expensive resources
    app.model = None  # Loaded on first use

    @app.before_first_request
    def lazy_init():
        # Model loaded after app is ready for traffic
        # First request waits, subsequent requests don't
        if app.model is None:
            app.model = load_large_model('model.pkl')

    # Use external cache, don't pre-warm in process
    app.redis = redis.from_url(os.environ['REDIS_URL'])

    # Health check without verifying all dependencies
    @app.route('/health')
    def health():
        return {'status': 'ok'}

    return app
# Startup: <5 seconds
# Ready to receive health checks immediately
```

**Techniques for fast startup:**

```python
# 1. Lazy loading
class LazyModel:
    def __init__(self, path):
        self._path = path
        self._model = None

    @property
    def model(self):
        if self._model is None:
            self._model = load_model(self._path)
        return self._model

# 2. Background initialization
import threading

def init_cache_background():
    """Run after app starts, doesn't block startup"""
    time.sleep(5)  # Wait for app to be stable
    warm_cache()

threading.Thread(target=init_cache_background, daemon=True).start()

# 3. Pre-built artifacts
# Move compilation to build stage, not runtime
# See: build-complexity-in-build.md
```

**Kubernetes readiness probe:**

```yaml
spec:
  containers:
  - name: app
    readinessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 2   # Start checking quickly
      periodSeconds: 5
    # Traffic routes only after readiness passes
    # Fast startup = fast traffic routing
```

**Benefits:**
- Autoscaler adds capacity within seconds of traffic spike
- Crashed processes replaced immediately
- Rolling deployments complete faster
- Better resource utilization

Reference: [The Twelve-Factor App - Disposability](https://12factor.net/disposability)
