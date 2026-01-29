---
title: Never Commit Secrets or Credentials to Version Control
impact: CRITICAL
impactDescription: prevents security breaches, credentials in git history are nearly impossible to fully remove
tags: config, security, secrets, git
---

## Never Commit Secrets or Credentials to Version Control

Secrets committed to git remain in the repository history forever, even after deletion. A twelve-factor app never contains credentials in its codebase. Use environment variables, secret managers, or encrypted secret files that are explicitly gitignored.

**Incorrect (secrets in code or config files):**

```python
# config.py - COMMITTED TO GIT
AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
STRIPE_KEY = "sk_live_abc123"
```

```yaml
# docker-compose.yml - COMMITTED TO GIT
services:
  app:
    environment:
      - DATABASE_PASSWORD=supersecret123
```

```bash
# .env file committed to git (common mistake)
API_KEY=secret_value
```

**Correct (secrets from external sources):**

```python
# config.py - safe to commit
import os

AWS_ACCESS_KEY = os.environ["AWS_ACCESS_KEY_ID"]
AWS_SECRET_KEY = os.environ["AWS_SECRET_ACCESS_KEY"]
STRIPE_KEY = os.environ["STRIPE_API_KEY"]
```

```gitignore
# .gitignore - prevent accidental commits
.env
.env.*
*.pem
*.key
secrets/
```

```yaml
# docker-compose.yml - references external secrets
services:
  app:
    env_file:
      - .env  # Not committed, each developer creates their own
    secrets:
      - db_password
secrets:
  db_password:
    external: true  # Managed by Docker Swarm or similar
```

**If you accidentally committed a secret:**

```bash
# 1. Rotate the credential IMMEDIATELY (it's compromised)
# 2. Remove from current code
# 3. Clean git history (complex, may require force push)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/secret" \
  --prune-empty --tag-name-filter cat -- --all
# 4. Still assume it's compromised - history might be cached/forked
```

**Benefits:**
- Repository can be safely open-sourced
- Credentials can be rotated without code changes
- Security audit is straightforward

Reference: [The Twelve-Factor App - Config](https://12factor.net/config)
