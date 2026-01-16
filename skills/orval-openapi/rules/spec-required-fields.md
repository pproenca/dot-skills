---
title: Mark Required Fields Explicitly
impact: CRITICAL
impactDescription: prevents optional chaining everywhere, improves type narrowing
tags: spec, required, types, nullability
---

## Mark Required Fields Explicitly

Always specify the `required` array for object schemas. Without it, Orval generates all properties as optional (`field?: type`), forcing unnecessary null checks throughout your code.

**Incorrect (missing required specification):**

```yaml
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
        email:
          type: string
        name:
          type: string
        avatar:
          type: string
      # No required array - all fields become optional
```

**Generated TypeScript (all optional):**

```typescript
interface User {
  id?: string;
  email?: string;
  name?: string;
  avatar?: string;
}

// Forces defensive coding everywhere
const displayName = user.name ?? user.email ?? 'Unknown';
```

**Correct (explicit required fields):**

```yaml
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
        email:
          type: string
        name:
          type: string
        avatar:
          type: string
      required:
        - id
        - email
        - name
```

**Generated TypeScript (correct nullability):**

```typescript
interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;  // Only truly optional field
}

// Clean code without defensive checks
const displayName = user.name;
```

**When NOT to use this pattern:**
- Fields that are genuinely optional in API responses
- Partial update request bodies where any field can be omitted

Reference: [OpenAPI Required Properties](https://swagger.io/docs/specification/data-models/data-types/)
