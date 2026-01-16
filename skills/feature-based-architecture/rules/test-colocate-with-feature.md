---
title: Colocate Tests with Features
impact: MEDIUM
impactDescription: Makes test coverage visible; ensures tests move with features
tags: test, colocation, organization, feature
---

## Colocate Tests with Features

Tests should live in the same feature folder as the code they test. When tests are in a separate tests/ folder, they become disconnected from the code, leading to missing coverage and orphaned tests.

**Incorrect (centralized test folder):**

```
src/
├── features/
│   ├── user/
│   │   └── components/
│   │       └── UserProfile.tsx
│   └── cart/
│       └── hooks/
│           └── useCart.ts
└── tests/              # Disconnected from features
    ├── user/
    │   └── UserProfile.test.tsx
    └── cart/
        └── useCart.test.ts
```

**Correct (colocated tests):**

```
src/features/
├── user/
│   ├── components/
│   │   ├── UserProfile.tsx
│   │   └── __tests__/
│   │       └── UserProfile.test.tsx
│   └── hooks/
│       ├── useUser.ts
│       └── __tests__/
│           └── useUser.test.ts
└── cart/
    ├── hooks/
    │   ├── useCart.ts
    │   └── __tests__/
    │       └── useCart.test.ts
    └── api/
        ├── get-cart.ts
        └── __tests__/
            └── get-cart.test.ts
```

**Alternative: Adjacent files:**

```
src/features/user/components/
├── UserProfile.tsx
└── UserProfile.test.tsx   # Same folder, no __tests__ subfolder
```

**Benefits:**
- Moving a feature moves its tests
- Deleting a feature deletes its tests
- Test coverage is visible in the feature folder
- Easy to see what's tested at a glance

**vitest.config.ts:**

```typescript
export default defineConfig({
  test: {
    include: ['src/**/*.test.{ts,tsx}'],
  },
});
```

Reference: [Bulletproof React - Project Structure](https://github.com/alan2207/bulletproof-react/blob/master/docs/project-structure.md)
