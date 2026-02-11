---
title: Avoid Partial Type Abuse for Builder Patterns
impact: HIGH
impactDescription: prevents accessing properties that were never set
tags: arch, partial, builder-pattern, type-safety
---

## Avoid Partial Type Abuse for Builder Patterns

`Partial<T>` makes every property optional, which means TypeScript cannot distinguish between "not yet set" and "intentionally omitted." Use discriminated states or builder types to model progressive construction.

**Incorrect (Partial allows incomplete objects to escape):**

```typescript
function createUser(input: Partial<User>): User {
  return {
    id: input.id ?? generateId(),
    name: input.name ?? "Unknown",
    email: input.email ?? "",  // Empty string — valid but wrong
    role: input.role ?? "viewer",
  }
}

const user = createUser({}) // All defaults — silent bug
```

**Correct (require mandatory fields, optional for the rest):**

```typescript
interface CreateUserInput {
  name: string
  email: string
  role?: "viewer" | "editor" | "admin"
}

function createUser(input: CreateUserInput): User {
  return {
    id: generateId(),
    name: input.name,
    email: input.email,
    role: input.role ?? "viewer",
  }
}

const user = createUser({}) // Compile error: missing name and email
```

**When NOT to use this pattern:**
- Patch/update operations where any subset of fields is valid (use `Partial<Pick<T, K>>`)
