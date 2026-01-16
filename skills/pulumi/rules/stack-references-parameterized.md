---
title: Parameterize Stack References
impact: MEDIUM-HIGH
impactDescription: enables environment promotion without code changes
tags: stack, references, config, parameterization
---

## Parameterize Stack References

Hardcoded stack reference names prevent environment promotion. Use configuration to specify source stacks, allowing the same code to reference different environments.

**Incorrect (hardcoded stack names):**

```typescript
// Hardcoded to production - cannot test against staging
const networkStack = new pulumi.StackReference("acme/networking/prod");
const vpcId = networkStack.getOutput("vpcId");

// Different code needed for each environment
// staging/index.ts has different stack reference
// Drift between environments is inevitable
```

**Correct (parameterized references):**

```typescript
const config = new pulumi.Config();
const environment = config.require("environment");
const orgName = config.get("orgName") ?? "acme";

// Stack reference constructed from config
const networkStack = new pulumi.StackReference(
  `${orgName}/networking/${environment}`
);
const vpcId = networkStack.getOutput("vpcId");

const dataStack = new pulumi.StackReference(
  `${orgName}/data/${environment}`
);
const dbEndpoint = dataStack.getOutput("dbEndpoint");
```

```yaml
# Pulumi.staging.yaml
config:
  myapp:environment: staging

# Pulumi.prod.yaml
config:
  myapp:environment: prod
```

**Correct (with validation):**

```typescript
const validEnvironments = ["dev", "staging", "prod"];
const environment = config.require("environment");

if (!validEnvironments.includes(environment)) {
  throw new Error(`Invalid environment: ${environment}`);
}

const networkStack = new pulumi.StackReference(
  `acme/networking/${environment}`
);
```

Reference: [Stack References](https://www.pulumi.com/docs/iac/concepts/stacks/#stackreferences)
