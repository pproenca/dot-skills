---
title: Use deleteBeforeReplace for Unique Constraints
impact: MEDIUM
impactDescription: prevents deployment failures from naming conflicts
tags: lifecycle, replace, delete, constraints
---

## Use deleteBeforeReplace for Unique Constraints

Some resources have globally unique identifiers (DNS names, IAM role names). Default create-before-delete replacement fails when the new resource cannot coexist with the old. Use `deleteBeforeReplace` for these cases.

**Incorrect (default replacement behavior):**

```typescript
const role = new aws.iam.Role("service-role", {
  name: "my-service-role", // Globally unique in AWS account
  assumeRolePolicy: JSON.stringify({ /* ... */ }),
});

// Changing assumeRolePolicy triggers replacement
// Pulumi tries to create new role with same name → FAILS
// Error: EntityAlreadyExists: Role with name my-service-role already exists
```

**Correct (delete-before-replace):**

```typescript
const role = new aws.iam.Role("service-role", {
  name: "my-service-role",
  assumeRolePolicy: JSON.stringify({ /* ... */ }),
}, {
  deleteBeforeReplace: true, // Delete old before creating new
});

// Replacement sequence:
// 1. Delete existing role
// 2. Create new role with same name
// Brief downtime but succeeds
```

**Correct (auto-naming to avoid issue):**

```typescript
const role = new aws.iam.Role("service-role", {
  // No explicit name - Pulumi generates unique name
  assumeRolePolicy: JSON.stringify({ /* ... */ }),
});

// Pulumi names it "service-role-a1b2c3d"
// Replacement creates "service-role-e4f5g6h"
// No naming conflict, no downtime
```

**When to use deleteBeforeReplace:**
- IAM roles/users with explicit names
- Route53 hosted zones
- CloudFront distributions with aliases
- Any resource with unique name constraints
