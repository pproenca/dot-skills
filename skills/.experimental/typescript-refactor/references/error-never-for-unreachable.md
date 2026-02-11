---
title: Use never to Mark Unreachable Code Paths
impact: MEDIUM
impactDescription: prevents silent fallthrough when union types expand
tags: error, never, unreachable, exhaustiveness
---

## Use never to Mark Unreachable Code Paths

The `never` type represents values that never occur. Use it to mark code paths that should be logically impossible — if the code becomes reachable due to a refactor, the compiler reports an error instead of allowing silent bugs.

**Incorrect (unreachable code assumed but not verified):**

```typescript
type UserRole = "admin" | "editor" | "viewer"

function getPermissionLevel(role: UserRole): number {
  if (role === "admin") return 3
  if (role === "editor") return 2
  if (role === "viewer") return 1
  return 0 // "Unreachable" — but if a new role is added, returns 0 silently
}
```

**Correct (never catches newly reachable paths):**

```typescript
type UserRole = "admin" | "editor" | "viewer"

function getPermissionLevel(role: UserRole): number {
  if (role === "admin") return 3
  if (role === "editor") return 2
  if (role === "viewer") return 1

  const _exhaustive: never = role // Compile error if a new role is added
  throw new Error(`Unknown role: ${_exhaustive}`)
}
```
