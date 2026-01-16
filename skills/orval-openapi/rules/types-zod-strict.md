---
title: Enable Zod Strict Mode for Safer Validation
impact: MEDIUM
impactDescription: catches unexpected fields, prevents data leakage
tags: types, zod, strict, validation
---

## Enable Zod Strict Mode for Safer Validation

Enable strict mode for Zod schema generation to reject objects with unexpected properties. This catches API changes and prevents accidental data exposure.

**Incorrect (non-strict mode):**

```typescript
// orval.config.ts
export default defineConfig({
  apiZod: {
    output: {
      client: 'zod',
      // No strict mode - extra fields pass through
    },
  },
});
```

**Unexpected data passes validation:**
```typescript
// API returns extra sensitive field
const response = {
  id: '123',
  email: 'user@example.com',
  internalNotes: 'VIP customer - discount approved',  // Leaked!
};

userSchema.parse(response);  // Passes, includes internalNotes
```

**Correct (strict mode enabled):**

```typescript
// orval.config.ts
export default defineConfig({
  apiZod: {
    output: {
      client: 'zod',
      override: {
        zod: {
          strict: {
            response: true,
            body: true,
            query: true,
            param: true,
            header: true,
          },
        },
      },
    },
  },
});
```

**Strict validation catches unexpected fields:**
```typescript
const response = {
  id: '123',
  email: 'user@example.com',
  internalNotes: 'VIP customer',  // Extra field
};

userSchema.parse(response);
// ZodError: Unrecognized key(s) in object: 'internalNotes'
```

**When NOT to use this pattern:**
- API intentionally returns extra fields you ignore
- Working with APIs you don't control that may add fields

Reference: [Orval Zod Strict Mode](https://orval.dev/reference/configuration/output)
