---
title: Isolate Secrets by Environment
impact: HIGH
impactDescription: prevents production credential access from development
tags: secrets, environment, isolation, security
---

## Isolate Secrets by Environment

Each environment should have its own secrets with separate access controls. Never share production secrets with development environments.

**Incorrect (shared secrets across environments):**

```yaml
# Pulumi.yaml - same secrets for all stacks
config:
  myapp:dbPassword:
    secure: AAABAAAAAgCF5...
  myapp:apiKey:
    secure: AAABAAAAAgCF5...

# Pulumi.dev.yaml
config:
  myapp:environment: dev

# Pulumi.prod.yaml
config:
  myapp:environment: prod

# Developers with dev access can see production secrets
# Compromise of dev environment exposes production credentials
```

**Correct (environment-specific secrets):**

```yaml
# Pulumi.dev.yaml
config:
  myapp:environment: dev
  myapp:dbPassword:
    secure: AAABAAAAAgCF5...dev-encrypted...
  myapp:apiKey:
    secure: AAABAAAAAgCF5...dev-encrypted...

# Pulumi.prod.yaml
config:
  myapp:environment: prod
  myapp:dbPassword:
    secure: AAABAAAAAgCF5...prod-encrypted...
  myapp:apiKey:
    secure: AAABAAAAAgCF5...prod-encrypted...
```

**Correct (Pulumi ESC environment isolation):**

```yaml
# environments/dev.yaml
values:
  database:
    fn::open::aws-secrets:
      name: dev/database-credentials
      region: us-west-2

# environments/prod.yaml
imports:
  - base  # Shared non-secret config
values:
  database:
    fn::open::aws-secrets:
      name: prod/database-credentials
      region: us-west-2
      # Different IAM roles control who can access prod secrets
```

```bash
# Developers can only access dev environment
pulumi env open dev  # Works
pulumi env open prod # Access denied (RBAC)
```

Reference: [Pulumi ESC Environments](https://www.pulumi.com/docs/esc/environments/)
