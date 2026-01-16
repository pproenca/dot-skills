---
title: Protect Stateful Resources
impact: MEDIUM
impactDescription: prevents accidental data loss
tags: lifecycle, protect, stateful, safety
---

## Protect Stateful Resources

Resources containing data (databases, storage, encryption keys) should be marked with `protect: true`. This prevents accidental deletion from code changes or `pulumi destroy`.

**Incorrect (unprotected stateful resources):**

```typescript
const database = new aws.rds.Instance("main", {
  engine: "postgres",
  instanceClass: "db.t3.large",
  allocatedStorage: 100,
  // No protection - accidentally deleted if removed from code
});

const encryptionKey = new aws.kms.Key("data-key", {
  description: "Encryption key for sensitive data",
  // Deletion destroys all encrypted data permanently
});
```

**Correct (protected stateful resources):**

```typescript
const database = new aws.rds.Instance("main", {
  engine: "postgres",
  instanceClass: "db.t3.large",
  allocatedStorage: 100,
}, {
  protect: true, // Cannot be deleted without explicit removal
});

const encryptionKey = new aws.kms.Key("data-key", {
  description: "Encryption key for sensitive data",
  deletionWindowInDays: 30, // AWS-level protection
}, {
  protect: true, // Pulumi-level protection
});

const bucket = new aws.s3.Bucket("data-lake", {
  versioning: { enabled: true },
}, {
  protect: true,
});
```

**To delete a protected resource:**

```bash
# Step 1: Remove protect in code
# Step 2: Run pulumi up to update state
# Step 3: Remove resource from code
# Step 4: Run pulumi up to delete

# Or use --target with explicit confirmation
pulumi destroy --target "urn:pulumi:prod::app::aws:rds/instance:Instance::main"
```

Reference: [Resource Options: protect](https://www.pulumi.com/docs/iac/concepts/resources/options/protect/)
