---
title: Narrow Values Instead of Using the Non-Null Assertion
impact: MEDIUM
impactDescription: prevents reintroduced null crashes
tags: unsafe, non-null-assertion, narrowing, null-safety
---

## Narrow Values Instead of Using the Non-Null Assertion

The `!` non-null assertion silences `strictNullChecks` without any proof, reintroducing exactly the `cannot read property of undefined` crashes the flag exists to prevent. Sprinkling `!` to clear migration errors trades a compile error for a runtime one. A guard or early return proves non-nullness to both the compiler and the runtime.

**Incorrect (non-null assertion — unproven, crashes when wrong):**

```typescript
function greet(users: Map<string, User>, id: string): string {
  return `Hi ${users.get(id)!.name}` // throws when id is absent
}
```

**Correct (narrow with a guard):**

```typescript
function greet(users: Map<string, User>, id: string): string {
  const user = users.get(id)
  if (!user) return "Hi there"
  return `Hi ${user.name}`
}
```

**When NOT to use this pattern:**

- Right after an existence check the compiler cannot follow across a helper
  boundary. Even then, prefer a custom assertion function (`assertExists`)
  over a bare `!`, so the check runs at runtime too.

Reference: [tsconfig: strictNullChecks](https://www.typescriptlang.org/tsconfig/#strictNullChecks)
