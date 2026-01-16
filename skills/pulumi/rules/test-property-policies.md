---
title: Use Policy as Code for Property Testing
impact: MEDIUM
impactDescription: 100% policy compliance enforcement
tags: test, policy, crossguard, validation
---

## Use Policy as Code for Property Testing

CrossGuard policies validate resource properties during preview and update. Unlike unit tests, policies run against real values from the cloud provider and enforce invariants across all stacks.

**Incorrect (manual review for compliance):**

```typescript
// Relying on code review to catch issues
const bucket = new aws.s3.Bucket("data", {
  // Reviewer must check: is versioning enabled?
  // Reviewer must check: is encryption configured?
  // Reviewer must check: is public access blocked?
});
// Human error leads to non-compliant resources
```

**Correct (automated policy enforcement):**

```typescript
// policy/index.ts
import * as policy from "@pulumi/policy";

new policy.PolicyPack("aws-security", {
  policies: [
    {
      name: "s3-no-public-read",
      description: "S3 buckets must not allow public read access",
      enforcementLevel: "mandatory",
      validateResource: policy.validateResourceOfType(aws.s3.Bucket, (bucket, args, reportViolation) => {
        if (bucket.acl === "public-read" || bucket.acl === "public-read-write") {
          reportViolation("S3 bucket must not have public read ACL");
        }
      }),
    },
    {
      name: "s3-versioning-enabled",
      description: "S3 buckets must have versioning enabled",
      enforcementLevel: "mandatory",
      validateResource: policy.validateResourceOfType(aws.s3.Bucket, (bucket, args, reportViolation) => {
        if (!bucket.versioning?.enabled) {
          reportViolation("S3 bucket must have versioning enabled");
        }
      }),
    },
  ],
});
```

```bash
# Run with policy pack
pulumi preview --policy-pack ./policy
# Deployment blocked if policies violated
```

Reference: [CrossGuard Policy as Code](https://www.pulumi.com/docs/iac/guides/crossguard/)
