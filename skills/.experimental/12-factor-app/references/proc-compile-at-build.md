---
title: Perform Asset Compilation and Bundling at Build Time Not Runtime
impact: MEDIUM-HIGH
impactDescription: ensures fast startup, prevents runtime compilation failures
tags: proc, build, assets, compilation
---

## Perform Asset Compilation and Bundling at Build Time Not Runtime

Asset compilation (JavaScript bundling, Sass compilation, image optimization) should happen during the build stage, not at runtime. The running process should serve pre-compiled assets, not compile on demand.

**Incorrect (runtime compilation):**

```python
# Django with runtime asset compilation
from django.conf import settings

# In development, this compiles on each request
# In production, this might work initially...
STATICFILES_STORAGE = 'pipeline.storage.PipelineStorage'

# But in 12-factor app:
# - Container restarts lose compiled assets
# - Each instance recompiles (wasted CPU, slow startup)
# - First request after deploy is slow
# - Compilation errors happen in production
```

```javascript
// Node.js with runtime bundling
const webpack = require('webpack');
const middleware = require('webpack-dev-middleware');

// Running webpack in production!
app.use(middleware(webpack(config)));
// Compiles on startup - slow
// Compiles on change - unnecessary in production
// Memory overhead of compiler in production
```

**Correct (build-time compilation):**

```dockerfile
# Multi-stage build with asset compilation
FROM node:20 AS assets
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build  # Webpack/Vite/esbuild runs HERE

FROM python:3.11-slim
WORKDIR /app
COPY --from=assets /app/dist /app/static  # Pre-built assets
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["gunicorn", "app:application"]
# No asset compilation at runtime
# Static files are ready to serve immediately
```

```python
# Django serving pre-built static files
STATIC_URL = '/static/'
STATIC_ROOT = '/app/static'
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.ManifestStaticFilesStorage'

# python manage.py collectstatic runs at BUILD time
# At runtime, files are already in STATIC_ROOT
```

```yaml
# CI pipeline
build:
  script:
    - npm ci
    - npm run build          # Compile assets
    - python manage.py collectstatic --noinput
    - docker build -t myapp:$SHA .
```

**Benefits:**
- Fast startup: no compilation at process start
- Consistent: all instances serve identical assets
- Early failure: compilation errors fail the build, not production
- Reduced runtime resources: no compiler in production memory

Reference: [The Twelve-Factor App - Processes](https://12factor.net/processes)
