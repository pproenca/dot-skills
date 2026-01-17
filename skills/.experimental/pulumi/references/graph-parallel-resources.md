---
title: Structure Resources for Maximum Parallelism
impact: CRITICAL
impactDescription: N× faster deployments where N is parallelism factor
tags: graph, parallelism, dependencies, performance
---

## Structure Resources for Maximum Parallelism

Pulumi deploys independent resources in parallel. Unnecessary dependencies create sequential bottlenecks. Structure resource graphs wide rather than deep.

**Incorrect (artificial sequential dependencies):**

```typescript
// Each resource waits for the previous one
const bucket1 = new aws.s3.Bucket("bucket-1", {});
const bucket2 = new aws.s3.Bucket("bucket-2", {
  tags: { after: bucket1.id }, // Unnecessary dependency
});
const bucket3 = new aws.s3.Bucket("bucket-3", {
  tags: { after: bucket2.id }, // Unnecessary dependency
});
// Total time: bucket1 + bucket2 + bucket3 = 30 seconds
```

**Correct (independent parallel resources):**

```typescript
// All buckets deploy simultaneously
const buckets = ["logs", "assets", "backups"].map(name =>
  new aws.s3.Bucket(`bucket-${name}`, {
    tags: { purpose: name },
  })
);
// Total time: max(bucket creation) = 10 seconds
```

**Correct (explicit parallelism control):**

```bash
# Increase parallelism for large stacks
pulumi up --parallel 50
# Default is 10, increase for stacks with many independent resources
```

**When sequential is necessary:**
- Database must exist before schema migration
- VPC must exist before subnets
- IAM role must exist before assuming it

Reference: [Pulumi CLI - pulumi up](https://www.pulumi.com/docs/iac/cli/commands/pulumi_up/)
