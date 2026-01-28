---
title: Use Strict Types Over any
impact: LOW-MEDIUM
impactDescription: Catches 15-30% more type errors at compile time, reduces runtime debugging
tags: idiom, typescript, type-safety, strict-mode
---

## Use Strict Types Over any

Using `any` defeats TypeScript's purpose and hides bugs that would otherwise be caught at compile time. Prefer `unknown` with type narrowing when the type is truly uncertain—this forces explicit type checking before use, making your code both safer and more self-documenting.

**Incorrect (using any bypasses type checking):**

```typescript
function processData(data: any) {
  // No type safety - runtime errors possible
  return data.items.map((item: any) => item.name.toUpperCase());
}

function parseResponse(response: any): any {
  return JSON.parse(response.body);
}
```

**Correct (using unknown with narrowing):**

```typescript
interface DataWithItems {
  items: Array<{ name: string }>;
}

function isDataWithItems(data: unknown): data is DataWithItems {
  return (
    typeof data === 'object' &&
    data !== null &&
    'items' in data &&
    Array.isArray((data as DataWithItems).items)
  );
}

function processData(data: unknown): string[] {
  if (!isDataWithItems(data)) {
    throw new Error('Invalid data structure');
  }
  return data.items.map(item => item.name.toUpperCase());
}

interface ApiResponse {
  body: string;
}

function parseResponse(response: ApiResponse): unknown {
  return JSON.parse(response.body);
}
```

### When to Allow any

- Legacy code migration where full typing isn't feasible yet
- Third-party libraries without type definitions (prefer `@types/*` packages)
- Explicit `// eslint-disable-next-line @typescript-eslint/no-explicit-any` with justification

### Benefits

- Compiler catches type mismatches before runtime
- IDE autocomplete works correctly
- Refactoring becomes safer with full type coverage
- Self-documenting code through explicit type contracts
