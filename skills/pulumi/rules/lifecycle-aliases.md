---
title: Use Aliases for Safe Resource Renaming
impact: MEDIUM
impactDescription: prevents delete-and-recreate on refactoring
tags: lifecycle, aliases, refactoring, renaming
---

## Use Aliases for Safe Resource Renaming

When renaming resources or moving them between components, use aliases to preserve identity. Without aliases, Pulumi treats renamed resources as new resources and deletes the old ones.

**Incorrect (renaming without alias):**

```typescript
// Before: resource named "old-bucket"
const bucket = new aws.s3.Bucket("old-bucket", {});

// After: renaming to "data-bucket"
const bucket = new aws.s3.Bucket("data-bucket", {});
// Pulumi will DELETE old-bucket and CREATE data-bucket
// All data in old-bucket is LOST
```

**Correct (alias preserves identity):**

```typescript
// Rename with alias pointing to old name
const bucket = new aws.s3.Bucket("data-bucket", {}, {
  aliases: [{ name: "old-bucket" }],
});
// Pulumi recognizes this as the same resource
// No deletion, no data loss
```

**Correct (moving between components):**

```typescript
// Before: bucket in root stack
// URN: urn:pulumi:prod::myapp::aws:s3/bucket:Bucket::data

// After: bucket moved into component
class DataStorage extends pulumi.ComponentResource {
  constructor(name: string) {
    super("acme:storage:DataStorage", name, {});

    const bucket = new aws.s3.Bucket("data", {}, {
      parent: this,
      aliases: [{
        // Alias to old URN before component existed
        name: "data",
        parent: pulumi.rootStackResource,
      }],
    });
  }
}
```

**Correct (multiple aliases during migration):**

```typescript
const bucket = new aws.s3.Bucket("data-bucket-v2", {}, {
  aliases: [
    { name: "data-bucket" },      // Previous name
    { name: "old-bucket" },        // Original name
    { type: "aws:s3/bucket:Bucket", name: "legacy-bucket" }, // Type alias
  ],
});
```

Reference: [Resource Aliases](https://www.pulumi.com/docs/iac/concepts/resources/options/aliases/)
