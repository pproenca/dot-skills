---
title: Separate Stacks by Deployment Lifecycle
impact: MEDIUM-HIGH
impactDescription: reduces blast radius and enables independent deployments
tags: stack, organization, lifecycle, separation
---

## Separate Stacks by Deployment Lifecycle

Resources with different change frequencies should live in separate stacks. Networking changes rarely, applications change frequently. Mixing them creates unnecessary risk and deployment friction.

**Incorrect (everything in one stack):**

```typescript
// infrastructure/index.ts - monolithic stack
// VPC changes yearly
const vpc = new aws.ec2.Vpc("main", { cidrBlock: "10.0.0.0/16" });
const subnets = createSubnets(vpc);

// Database changes monthly
const database = new aws.rds.Instance("main", { /* ... */ });

// Application changes daily
const appFunction = new aws.lambda.Function("api", {
  code: new pulumi.asset.FileArchive("./dist"),
  // ...
});

// Deploying app change risks touching VPC and database
// All team members need access to sensitive networking config
```

**Correct (lifecycle-based separation):**

```typescript
// stacks/networking/index.ts - changes rarely
const vpc = new aws.ec2.Vpc("main", { cidrBlock: "10.0.0.0/16" });
export const vpcId = vpc.id;
export const subnetIds = subnets.map(s => s.id);

// stacks/data/index.ts - changes occasionally
const networkStack = new pulumi.StackReference("org/networking/prod");
const database = new aws.rds.Instance("main", {
  dbSubnetGroupName: subnetGroup.name,
});
export const dbEndpoint = database.endpoint;

// stacks/application/index.ts - changes frequently
const dataStack = new pulumi.StackReference("org/data/prod");
const appFunction = new aws.lambda.Function("api", {
  environment: {
    variables: { DB_HOST: dataStack.getOutput("dbEndpoint") },
  },
});
```

**Benefits:**
- Application deploys don't risk networking changes
- Teams can deploy independently
- Smaller stacks = faster previews
