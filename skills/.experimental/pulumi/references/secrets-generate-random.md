---
title: Generate Secrets with Random Provider
impact: HIGH
impactDescription: eliminates manual secret management
tags: secrets, random, generation, automation
---

## Generate Secrets with Random Provider

Instead of manually creating and storing secrets, use Pulumi's random provider to generate passwords, keys, and other sensitive values. Generated secrets are automatically marked as secret in state.

**Incorrect (manual secret management):**

```bash
# Manual process: generate password externally
openssl rand -base64 32
# Copy output, paste into config
pulumi config set --secret dbPassword "generated-password"
# Repeat for every environment
```

```typescript
const config = new pulumi.Config();
const dbPassword = config.requireSecret("dbPassword");
// Manual rotation requires updating config and redeploying
```

**Correct (generated secrets):**

```typescript
import * as random from "@pulumi/random";

const dbPassword = new random.RandomPassword("db-password", {
  length: 32,
  special: true,
  overrideSpecial: "!#$%&*()-_=+[]{}:?",
});

const database = new aws.rds.Instance("db", {
  username: "admin",
  password: dbPassword.result, // Automatically secret
  // ...
});

// Store in Secrets Manager for application access
const secret = new aws.secretsmanager.Secret("db-password", {});
const secretVersion = new aws.secretsmanager.SecretVersion("db-password-v1", {
  secretId: secret.id,
  secretString: dbPassword.result,
});
```

**Correct (keepers for controlled rotation):**

```typescript
const dbPassword = new random.RandomPassword("db-password", {
  length: 32,
  special: true,
  keepers: {
    // Change this value to trigger password rotation
    rotation: "2024-01-15",
  },
});
// Updating rotation date generates new password
```

Reference: [Random Provider](https://www.pulumi.com/registry/packages/random/)
