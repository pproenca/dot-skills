---
title: Minimize Stack Reference Depth
impact: CRITICAL
impactDescription: reduces deployment coupling and cascade failures
tags: graph, stack-references, coupling, architecture
---

## Minimize Stack Reference Depth

Deep stack reference chains create deployment bottlenecks. Each reference adds latency and failure points. Keep reference depth to 2-3 levels maximum.

**Incorrect (deep reference chain):**

```typescript
// networking/index.ts
export const vpcId = vpc.id;

// security/index.ts
const networkStack = new pulumi.StackReference("org/networking/prod");
export const securityGroupId = sg.id;

// database/index.ts
const securityStack = new pulumi.StackReference("org/security/prod");
export const dbEndpoint = db.endpoint;

// cache/index.ts
const dbStack = new pulumi.StackReference("org/database/prod");
export const cacheEndpoint = cache.endpoint;

// application/index.ts
const cacheStack = new pulumi.StackReference("org/cache/prod");
// 5 stacks deep - any failure blocks entire chain
// Deploying application requires all 4 upstream stacks to be healthy
```

**Correct (shallow reference structure):**

```typescript
// platform/index.ts - shared infrastructure layer
const vpc = new aws.ec2.Vpc("main", { /* ... */ });
const sg = new aws.ec2.SecurityGroup("shared", { vpcId: vpc.id });
const db = new aws.rds.Instance("main", { /* ... */ });
const cache = new aws.elasticache.Cluster("main", { /* ... */ });

export const vpcId = vpc.id;
export const securityGroupId = sg.id;
export const dbEndpoint = db.endpoint;
export const cacheEndpoint = cache.endpoint;

// application/index.ts - single reference to platform
const platform = new pulumi.StackReference("org/platform/prod");

const app = new aws.lambda.Function("api", {
  vpcConfig: {
    subnetIds: platform.getOutput("privateSubnetIds"),
    securityGroupIds: [platform.getOutput("securityGroupId")],
  },
  environment: {
    variables: {
      DB_HOST: platform.getOutput("dbEndpoint"),
      CACHE_HOST: platform.getOutput("cacheEndpoint"),
    },
  },
});
// 2 levels deep - platform changes don't cascade through multiple stacks
```
