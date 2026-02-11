---
title: Use satisfies for Config Objects Instead of Type Annotations
impact: CRITICAL
impactDescription: preserves literal types while validating structure
tags: arch, satisfies, inference, config, type-safety
---

## Use satisfies for Config Objects Instead of Type Annotations

Type annotations widen literals to their base types, losing precise inference. The `satisfies` operator validates conformance while preserving the exact literal types, enabling autocomplete and type-safe property access.

**Incorrect (annotation widens literal types):**

```typescript
interface RouteConfig {
  [path: string]: { method: "GET" | "POST"; auth: boolean }
}

const routes: RouteConfig = {
  "/users": { method: "GET", auth: true },
  "/login": { method: "POST", auth: false },
}

routes["/users"].method // Type: "GET" | "POST" — lost the literal
```

**Correct (satisfies preserves literals):**

```typescript
interface RouteConfig {
  [path: string]: { method: "GET" | "POST"; auth: boolean }
}

const routes = {
  "/users": { method: "GET", auth: true },
  "/login": { method: "POST", auth: false },
} satisfies RouteConfig

routes["/users"].method // Type: "GET" — literal preserved
```

Reference: [TypeScript 4.9 Release Notes](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-9.html)
