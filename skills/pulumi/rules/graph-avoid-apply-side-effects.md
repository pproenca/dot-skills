---
title: Avoid Side Effects in Apply Functions
impact: CRITICAL
impactDescription: prevents unpredictable behavior and resource leaks
tags: graph, apply, side-effects, predictability
---

## Avoid Side Effects in Apply Functions

Apply functions run during preview and update operations. Side effects like creating resources, writing files, or making API calls inside apply lead to unpredictable behavior and resources not tracked in state.

**Incorrect (creating resources inside apply):**

```typescript
const config = new pulumi.Config();
const clusterName = config.require("clusterName");

const cluster = new aws.eks.Cluster("cluster", { name: clusterName });

cluster.endpoint.apply(endpoint => {
  // WRONG: Resource created inside apply is not tracked
  new aws.ec2.SecurityGroupRule("allow-cluster", {
    securityGroupId: cluster.vpcConfig.clusterSecurityGroupId,
    type: "ingress",
    fromPort: 443,
    toPort: 443,
    cidrBlocks: ["10.0.0.0/8"],
  });
});
// Security group rule exists but isn't in Pulumi state
```

**Correct (resource at top level with output dependencies):**

```typescript
const config = new pulumi.Config();
const clusterName = config.require("clusterName");

const cluster = new aws.eks.Cluster("cluster", { name: clusterName });

// Resource at top level, properly tracked
const allowCluster = new aws.ec2.SecurityGroupRule("allow-cluster", {
  securityGroupId: cluster.vpcConfig.clusterSecurityGroupId,
  type: "ingress",
  fromPort: 443,
  toPort: 443,
  cidrBlocks: ["10.0.0.0/8"],
});
```

**When apply is appropriate:**
- Transforming output values (string manipulation, formatting)
- Logging or debugging during development
- Computing derived values that don't create resources
