---
title: Keep Stacks Under 500 Resources
impact: CRITICAL
impactDescription: 10-100× faster preview and deployment
tags: pstate, stack-size, performance, architecture
---

## Keep Stacks Under 500 Resources

State operations scale with resource count. Stacks exceeding 500 resources experience exponential slowdown in preview, refresh, and update operations. Split large infrastructure into multiple focused stacks connected via stack references.

**Incorrect (monolithic stack with thousands of resources):**

```typescript
// Single stack managing entire infrastructure
const vpc = new aws.ec2.Vpc("main-vpc", { cidrBlock: "10.0.0.0/16" });

// 200 EC2 instances
for (let i = 0; i < 200; i++) {
  new aws.ec2.Instance(`instance-${i}`, { /* ... */ });
}

// 50 RDS databases
for (let i = 0; i < 50; i++) {
  new aws.rds.Instance(`db-${i}`, { /* ... */ });
}

// 100 Lambda functions, 500 IAM roles, etc.
// Preview takes 20+ minutes, updates take hours
```

**Correct (split into focused stacks):**

```typescript
// networking/index.ts - ~50 resources
const vpc = new aws.ec2.Vpc("main-vpc", { cidrBlock: "10.0.0.0/16" });
export const vpcId = vpc.id;
export const subnetIds = subnets.map(s => s.id);

// compute/index.ts - ~200 resources
const networkStack = new pulumi.StackReference("org/networking/prod");
const vpcId = networkStack.getOutput("vpcId");
// EC2 instances reference networking outputs

// databases/index.ts - ~50 resources
// RDS instances in separate stack with its own lifecycle
```

**Benefits:**
- Preview completes in seconds instead of minutes
- Teams can deploy independently without blocking each other
- Blast radius limited to single domain on failures

Reference: [Organizing Projects & Stacks](https://www.pulumi.com/docs/iac/using-pulumi/organizing-projects-stacks/)
