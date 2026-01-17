---
title: Use retainOnDelete for Shared Resources
impact: MEDIUM
impactDescription: prevents orphaned dependencies across stacks
tags: lifecycle, retain, delete, shared
---

## Use retainOnDelete for Shared Resources

Resources referenced by other stacks or external systems should use `retainOnDelete`. This prevents cascading failures when refactoring infrastructure organization.

**Incorrect (hard delete of shared resource):**

```typescript
// networking/index.ts
const vpc = new aws.ec2.Vpc("shared-vpc", {
  cidrBlock: "10.0.0.0/16",
});
export const vpcId = vpc.id;

// Multiple other stacks reference this VPC
// Deleting this stack destroys the VPC
// All dependent resources in other stacks break
```

**Correct (retain shared resources):**

```typescript
// networking/index.ts
const vpc = new aws.ec2.Vpc("shared-vpc", {
  cidrBlock: "10.0.0.0/16",
}, {
  retainOnDelete: true, // VPC remains when stack is destroyed
});

export const vpcId = vpc.id;

// Destroying networking stack:
// - Pulumi removes VPC from state
// - VPC continues to exist in AWS
// - Dependent stacks continue working
```

**Correct (with deletedWith for child resources):**

```typescript
const vpc = new aws.ec2.Vpc("shared-vpc", {
  cidrBlock: "10.0.0.0/16",
}, {
  retainOnDelete: true,
});

// Subnets should be retained along with VPC
const subnet = new aws.ec2.Subnet("shared-subnet", {
  vpcId: vpc.id,
  cidrBlock: "10.0.1.0/24",
}, {
  retainOnDelete: true,
  deletedWith: vpc, // If VPC is somehow deleted, don't call subnet delete API
});
```

**Use cases:**
- VPCs shared across multiple applications
- KMS keys used by multiple services
- S3 buckets with cross-account access
- Resources being migrated to another stack
