---
title: Use External Secret Managers for Production
impact: HIGH
impactDescription: eliminates static secrets and enables rotation
tags: secrets, vault, esc, rotation, security
---

## Use External Secret Managers for Production

Static secrets in config files cannot be rotated without redeployment. Use Pulumi ESC or external secret managers like HashiCorp Vault for dynamic secret retrieval and automatic rotation.

**Incorrect (static secrets in config):**

```typescript
const config = new pulumi.Config();
const awsAccessKey = config.requireSecret("awsAccessKey");
const awsSecretKey = config.requireSecret("awsSecretKey");

// Static credentials - cannot rotate without config update
// Leaked credentials require manual rotation
```

**Correct (Pulumi ESC for dynamic secrets):**

```yaml
# environments/production.yaml
values:
  aws:
    login:
      fn::open::aws-login:
        oidc:
          roleArn: arn:aws:iam::123456789:role/pulumi-deploy
          sessionName: pulumi-deploy
  pulumiConfig:
    aws:region: us-west-2
```

```typescript
// Credentials fetched dynamically via OIDC
// No static secrets, automatic token refresh
const bucket = new aws.s3.Bucket("data", {});
```

**Correct (HashiCorp Vault integration):**

```typescript
import * as vault from "@pulumi/vault";

// Fetch dynamic database credentials
const dbCreds = vault.database.getSecretBackendConnection({
  backend: "database",
  name: "postgres",
});

const database = new aws.rds.Instance("db", {
  username: dbCreds.then(c => c.username),
  password: pulumi.secret(dbCreds.then(c => c.password)),
});
// Credentials auto-rotate based on Vault policy
```

**Benefits:**
- No static credentials to leak
- Automatic credential rotation
- Centralized secret audit trail

Reference: [Pulumi ESC](https://www.pulumi.com/docs/esc/)
