---
title: Understand Excess Property Checks on Object Literals
impact: LOW-MEDIUM
impactDescription: prevents silent extra-property bugs in direct assignments
tags: quirk, excess-property-checks, object-literals, structural-typing
---

## Understand Excess Property Checks on Object Literals

TypeScript only checks for extra properties when assigning object literals directly. Passing through an intermediate variable bypasses this check due to structural typing. Understanding this quirk prevents both false confidence and unexpected errors.

**Incorrect (intermediate variable bypasses check):**

```typescript
interface CreateUserInput {
  name: string
  email: string
}

const input = {
  name: "Alice",
  email: "alice@example.com",
  role: "admin", // Extra property — no error through intermediate variable
}

function createUser(input: CreateUserInput) { /* ... */ }
createUser(input) // Compiles — "role" silently ignored
```

**Correct (direct literal catches extra properties):**

```typescript
interface CreateUserInput {
  name: string
  email: string
}

function createUser(input: CreateUserInput) { /* ... */ }

createUser({
  name: "Alice",
  email: "alice@example.com",
  role: "admin", // Compile error: 'role' does not exist in type 'CreateUserInput'
})
```

**Note:** Use `satisfies` to get excess property checking even with intermediate variables:

```typescript
const input = {
  name: "Alice",
  email: "alice@example.com",
  role: "admin", // Error with satisfies
} satisfies CreateUserInput
```

Reference: [TypeScript Handbook - Excess Property Checks](https://www.typescriptlang.org/docs/handbook/2/objects.html#excess-property-checks)
