---
title: Prevent Secret Leakage in State
impact: HIGH
impactDescription: prevents credential exposure in checkpoints
tags: secrets, state, leakage, security
---

## Prevent Secret Leakage in State

Pulumi marks outputs as secrets when they derive from secret inputs. However, using apply() to extract secret values can break this tracking. Ensure secrets propagate correctly through transformations.

**Incorrect (secret leakage through apply):**

```typescript
const config = new pulumi.Config();
const apiKey = config.requireSecret("apiKey");

// apply() loses secret marking if not careful
const keyPrefix = apiKey.apply(key => key.substring(0, 4));
// keyPrefix is NOT marked as secret, may appear in state/logs

const functionEnv = {
  API_KEY_PREFIX: keyPrefix, // Leaks partial secret to state
};
```

**Correct (preserving secret marking):**

```typescript
const config = new pulumi.Config();
const apiKey = config.requireSecret("apiKey");

// Use pulumi.secret() to explicitly mark derived values
const keyPrefix = apiKey.apply(key => key.substring(0, 4));
const secretPrefix = pulumi.secret(keyPrefix);

// Or use Output.secret() for transformations
const maskedKey = pulumi.all([apiKey]).apply(([key]) =>
  pulumi.secret(`${key.substring(0, 4)}****`)
);
```

**Correct (secret in resource outputs):**

```typescript
const password = new random.RandomPassword("db-password", {
  length: 32,
  special: true,
});

// RandomPassword.result is automatically secret
const database = new aws.rds.Instance("db", {
  password: password.result, // Stays secret in state
});

// Export as secret
export const dbPassword = pulumi.secret(password.result);
```

Reference: [Secrets](https://www.pulumi.com/docs/iac/concepts/secrets/)
