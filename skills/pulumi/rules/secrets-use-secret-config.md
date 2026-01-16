---
title: Use Secret Config for Sensitive Values
impact: HIGH
impactDescription: prevents credential exposure in state and logs
tags: secrets, config, encryption, security
---

## Use Secret Config for Sensitive Values

Use `pulumi config set --secret` to encrypt sensitive configuration values. Secret values are encrypted in the config file and marked as secrets throughout the Pulumi program.

**Incorrect (plaintext secrets in config):**

```bash
# Stores password in plaintext in Pulumi.prod.yaml
pulumi config set dbPassword "super-secret-password"
```

```yaml
# Pulumi.prod.yaml - visible to anyone with repo access
config:
  myapp:dbPassword: super-secret-password
```

**Correct (encrypted secrets):**

```bash
# Encrypts password before storing
pulumi config set --secret dbPassword "super-secret-password"
```

```yaml
# Pulumi.prod.yaml - encrypted, safe to commit
config:
  myapp:dbPassword:
    secure: AAABAAAAAgCF5...encrypted...
```

**Correct (using secret config in code):**

```typescript
const config = new pulumi.Config();

// Use requireSecret to ensure value stays encrypted
const dbPassword = config.requireSecret("dbPassword");

const database = new aws.rds.Instance("db", {
  password: dbPassword, // Automatically marked as secret in state
  // ...
});

// WRONG: getSecret returns plain Output, use requireSecret
const password = config.get("dbPassword"); // Not marked as secret
```

**Note:** Secrets are encrypted in config and state but decrypted during deployment. Avoid logging or exporting secret values.

Reference: [Secrets Handling](https://www.pulumi.com/docs/iac/concepts/secrets/)
