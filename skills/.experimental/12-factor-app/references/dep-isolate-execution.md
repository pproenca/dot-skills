---
title: Isolate Dependencies to Prevent System Package Leakage
impact: CRITICAL
impactDescription: prevents version conflicts, ensures consistent behavior across environments
tags: dep, isolation, virtualenv, containers
---

## Isolate Dependencies to Prevent System Package Leakage

A twelve-factor app uses a dependency isolation tool during execution to ensure no implicit dependencies "leak in" from the surrounding system. This guarantees the app runs identically regardless of what packages are installed globally.

**Incorrect (relying on system packages):**

```bash
# Globally installed packages pollute the environment
sudo pip install requests==2.25.0  # System-wide

# App expects requests 2.31.0 but gets 2.25.0
python app.py
# ImportError: cannot import name 'JSONDecodeError' from 'requests'

# Another app needs requests 2.20.0 - conflict!
```

**Correct (isolated environment):**

```bash
# Python: Use virtual environments
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
# All packages installed in .venv/, isolated from system

# Node.js: node_modules provides isolation by default
npm install
# All packages in ./node_modules/

# Ruby: Use bundler with bundle exec
bundle install --path vendor/bundle
bundle exec ruby app.rb
```

**Alternative (containerized isolation):**

```dockerfile
# Dockerfile provides complete isolation
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
CMD ["python", "app.py"]
# Container has only declared dependencies, nothing from host
```

**Benefits:**
- App behavior is identical across developer machines, CI, and production
- Multiple apps on the same machine can use different dependency versions
- Upgrading system packages never breaks existing apps
- Security vulnerabilities in system packages don't affect isolated apps

Reference: [The Twelve-Factor App - Dependencies](https://12factor.net/dependencies)
