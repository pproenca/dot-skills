---
title: Use dependsOn Only for External Dependencies
impact: CRITICAL
impactDescription: prevents hidden ordering issues
tags: graph, dependsOn, dependencies, ordering
---

## Use dependsOn Only for External Dependencies

The `dependsOn` option creates explicit ordering when Pulumi cannot infer dependencies from outputs. Overuse creates unnecessary sequential execution. Use it only for external or implicit dependencies.

**Incorrect (redundant dependsOn):**

```typescript
const vpc = new aws.ec2.Vpc("main", { cidrBlock: "10.0.0.0/16" });

const subnet = new aws.ec2.Subnet("subnet", {
  vpcId: vpc.id, // Already creates dependency
  cidrBlock: "10.0.1.0/24",
}, {
  dependsOn: [vpc], // Redundant - slows down graph resolution
});
```

**Correct (dependsOn for implicit dependency):**

```typescript
const dbInstance = new aws.rds.Instance("db", {
  engine: "postgres",
  instanceClass: "db.t3.micro",
  allocatedStorage: 20,
});

// Migration must run after database is ready
// But migration doesn't use any db outputs
const migration = new command.local.Command("migrate", {
  create: "npm run db:migrate",
  environment: {
    DATABASE_URL: dbInstance.endpoint,
  },
}, {
  dependsOn: [dbInstance], // Necessary - ensures db is fully ready
});
```

**Correct (dependsOn for eventual consistency):**

```typescript
const iamRole = new aws.iam.Role("role", { /* ... */ });
const policy = new aws.iam.RolePolicy("policy", {
  role: iamRole.name,
  policy: JSON.stringify({ /* ... */ }),
});

// AWS IAM has eventual consistency - role may not be assumable immediately
const lambda = new aws.lambda.Function("fn", {
  role: iamRole.arn,
  // ...
}, {
  dependsOn: [policy], // Wait for policy attachment to propagate
});
```
