---
title: Use OpenAPI Examples for Realistic Mocks
impact: MEDIUM
impactDescription: 100% deterministic mock data vs random Faker values
tags: mock, examples, faker, realism
---

## Use OpenAPI Examples for Realistic Mocks

Configure mocks to use examples from your OpenAPI spec. This produces more realistic and consistent mock data than random Faker values.

**Incorrect (random Faker data):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: true,  // Uses Faker by default
    },
  },
});
```

**Generated mock data is unrealistic:**
```typescript
// Random Faker data
{
  id: 'a3b2c1d4-e5f6-...',
  email: 'Malvina_Cruickshank42@yahoo.com',  // Not realistic
  name: 'Laverne Schimmel',  // Random name
  role: 'Principal Functionality Architect',  // Nonsense
}
```

**Correct (use OpenAPI examples):**

```yaml
# openapi.yaml
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
          example: 'usr_123456'
        email:
          type: string
          example: 'john.doe@company.com'
        name:
          type: string
          example: 'John Doe'
        role:
          type: string
          enum: [admin, user, guest]
          example: 'user'
```

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: {
        useExamples: true,  // Prefer examples from spec
      },
    },
  },
});
```

**Generated mock uses examples:**
```typescript
{
  id: 'usr_123456',
  email: 'john.doe@company.com',
  name: 'John Doe',
  role: 'user',
}
```

**Benefits:**
- Consistent, predictable test data
- Examples match expected production formats
- Easier to assert on known values

Reference: [Orval Mock Options](https://orval.dev/reference/configuration/output)
