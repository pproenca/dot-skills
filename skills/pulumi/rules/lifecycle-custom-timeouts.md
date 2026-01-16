---
title: Set Custom Timeouts for Long-Running Resources
impact: MEDIUM
impactDescription: prevents premature deployment failures
tags: lifecycle, timeouts, long-running, customization
---

## Set Custom Timeouts for Long-Running Resources

Some resources (RDS, EKS clusters, CloudFront distributions) take longer to create than default timeouts. Set custom timeouts to prevent false failures.

**Incorrect (default timeouts for slow resources):**

```typescript
const cluster = new aws.eks.Cluster("main", {
  name: "production",
  roleArn: eksRole.arn,
  vpcConfig: { subnetIds: subnets.map(s => s.id) },
});
// Default timeout: 30 minutes
// EKS cluster creation can take 20-40 minutes
// Intermittent timeout failures on slow days
```

**Correct (custom timeouts):**

```typescript
const cluster = new aws.eks.Cluster("main", {
  name: "production",
  roleArn: eksRole.arn,
  vpcConfig: { subnetIds: subnets.map(s => s.id) },
}, {
  customTimeouts: {
    create: "60m", // Allow up to 60 minutes for creation
    update: "60m",
    delete: "30m",
  },
});
```

**Correct (RDS with custom timeouts):**

```typescript
const database = new aws.rds.Instance("main", {
  engine: "postgres",
  engineVersion: "14.9",
  instanceClass: "db.r5.2xlarge",
  allocatedStorage: 500,
  storageType: "io1",
  iops: 10000,
}, {
  customTimeouts: {
    create: "90m", // Large databases take time to provision
    update: "90m", // Storage modifications are slow
    delete: "60m",
  },
});
```

**Resources that commonly need custom timeouts:**
- AWS EKS Cluster (30-45 minutes)
- AWS RDS Instance (15-60 minutes depending on size)
- AWS CloudFront Distribution (15-30 minutes)
- AWS ElastiCache Cluster (10-20 minutes)
- Azure AKS Cluster (10-20 minutes)
- GCP GKE Cluster (10-15 minutes)
