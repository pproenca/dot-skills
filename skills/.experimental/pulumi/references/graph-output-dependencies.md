---
title: Use Outputs to Express True Dependencies
impact: CRITICAL
impactDescription: eliminates false dependencies and enables parallelism
tags: graph, outputs, dependencies, apply
---

## Use Outputs to Express True Dependencies

Pulumi tracks dependencies through Output values. Pass outputs directly to dependent resources instead of using `apply()` to extract values prematurely.

**Incorrect (breaking dependency chain with apply):**

```typescript
const vpc = new aws.ec2.Vpc("main", { cidrBlock: "10.0.0.0/16" });

// apply() extracts value but loses dependency tracking
vpc.id.apply(vpcId => {
  // This subnet has no tracked dependency on vpc
  const subnet = new aws.ec2.Subnet("subnet", {
    vpcId: vpcId, // String, not Output - dependency lost
    cidrBlock: "10.0.1.0/24",
  });
});
// Subnet may attempt creation before VPC exists
```

**Correct (preserving Output chain):**

```typescript
const vpc = new aws.ec2.Vpc("main", { cidrBlock: "10.0.0.0/16" });

const subnet = new aws.ec2.Subnet("subnet", {
  vpcId: vpc.id, // Output<string> - dependency tracked
  cidrBlock: "10.0.1.0/24",
});
// Pulumi knows subnet depends on vpc
```

**Correct (combining multiple outputs):**

```typescript
const vpc = new aws.ec2.Vpc("main", { cidrBlock: "10.0.0.0/16" });
const subnet = new aws.ec2.Subnet("subnet", {
  vpcId: vpc.id,
  cidrBlock: "10.0.1.0/24",
});
const sg = new aws.ec2.SecurityGroup("sg", { vpcId: vpc.id });

const instance = new aws.ec2.Instance("server", {
  subnetId: subnet.id,
  vpcSecurityGroupIds: [sg.id],
  // Dependencies automatically tracked through outputs
});
```

Reference: [Inputs and Outputs](https://www.pulumi.com/docs/iac/concepts/inputs-outputs/)
