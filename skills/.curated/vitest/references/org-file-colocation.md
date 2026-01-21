---
title: Colocate Test Files with Source Files
impact: LOW
impactDescription: Reduces navigation overhead and improves test discoverability
tags: org, colocation, file-structure, discoverability
---

## Colocate Test Files with Source Files

Placing tests in a separate `__tests__` directory far from source files makes them hard to find and maintain. Colocating tests next to their source files improves discoverability and encourages testing.

**Harder to maintain (separate directory):**

```
src/
  components/
    Button.tsx
    UserList.tsx
  utils/
    format.ts
    validate.ts
tests/
  components/
    Button.test.tsx
    UserList.test.tsx
  utils/
    format.test.ts
    validate.test.ts
```

**Easier to maintain (colocated):**

```
src/
  components/
    Button.tsx
    Button.test.tsx
    UserList.tsx
    UserList.test.tsx
  utils/
    format.ts
    format.test.ts
    validate.ts
    validate.test.ts
```

**Vitest configuration:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Match test files next to source
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
  },
})
```

**Alternative: Adjacent test directories:**

```
src/
  components/
    Button/
      Button.tsx
      Button.test.tsx
      index.ts
    UserList/
      UserList.tsx
      UserList.test.tsx
      UserList.stories.tsx
      index.ts
```

**Build exclusion:**

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      external: [/\.test\.tsx?$/], // Exclude test files from build
    },
  },
})
```

**Benefits:**
- Easy to find tests for any file
- Missing tests are obvious
- Related files stay together

Reference: [Vitest Include Patterns](https://vitest.dev/config/#include)
