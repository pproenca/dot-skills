---
title: Use State Export/Import for Migrations
impact: CRITICAL
impactDescription: prevents resource recreation during refactoring
tags: pstate, migration, export, import, refactoring
---

## Use State Export/Import for Migrations

When refactoring code structure or moving resources between stacks, use state export/import to preserve resource identity. Without this, Pulumi treats renamed resources as delete-and-create operations.

**Incorrect (renaming resource in code):**

```typescript
// Before: resource has URN ending in "old-bucket"
const bucket = new aws.s3.Bucket("old-bucket", { /* ... */ });

// After: changing name triggers delete + create
const bucket = new aws.s3.Bucket("new-bucket", { /* ... */ });
// Pulumi will DELETE old-bucket and CREATE new-bucket
// All data in the bucket is LOST
```

**Correct (state manipulation for rename):**

```bash
# Step 1: Export current state
pulumi stack export --file state.json

# Step 2: Update URN in state.json
# Change "old-bucket" to "new-bucket" in resource URN

# Step 3: Import modified state
pulumi stack import --file state.json

# Step 4: Update code to match new name
# Now pulumi preview shows no changes
```

**Alternative (using aliases):**

```typescript
const bucket = new aws.s3.Bucket("new-bucket", {
  // ...bucket config
}, {
  aliases: [{ name: "old-bucket" }],
});
// Pulumi recognizes this as the same resource
```

Reference: [Resource Aliases](https://www.pulumi.com/docs/iac/concepts/resources/options/aliases/)
