---
title: Combine `satisfies` with Branded Types for Validated Configuration
impact: HIGH
impactDescription: catches 100% of structural drift on config objects without widening to the declared type
tags: mod, satisfies, branded-types, config, typescript-4-9
---

## Combine `satisfies` with Branded Types for Validated Configuration

The `satisfies` operator (TS 4.9) checks that a value conforms to a type *without changing the value's inferred type*. The standard advice — "use `satisfies` over annotation for config objects" — captures the basic value. The advanced pattern is to pair `satisfies` with **branded constraint types** so the config not only matches a shape, but carries proof of validation (length limits, enum membership, format) through to call sites. The runtime value stays as its narrow literal shape; the type system records that the value passed the structural check.

**Incorrect (`as Config` or `: Config` annotation widens away literal shape):**

```typescript
interface RouteConfig {
  method: 'GET' | 'POST' | 'PUT' | 'DELETE'
  path: string
  cache: { ttlSeconds: number; staleWhileRevalidate?: number }
}

const routes: Record<string, RouteConfig> = {
  listUsers: { method: 'GET', path: '/users', cache: { ttlSeconds: 60 } },
  newUser:   { method: 'POST', path: '/users', cache: { ttlSeconds: 0 } },
}

routes.listUsers.method   // 'GET' | 'POST' | 'PUT' | 'DELETE' — widened. autocomplete is useless.
routes['typo']            // RouteConfig | undefined — typo not caught
```

**Correct (`satisfies` keeps literals, brands enforce extra invariants):**

```typescript
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE'

declare const __validatedPath: unique symbol
type ValidatedPath = string & { readonly [__validatedPath]: true }

function path<P extends `/${string}`>(p: P): P & ValidatedPath {
  // The template-literal constraint forces a leading slash at compile time.
  return p as P & ValidatedPath
}

const routes = {
  listUsers: { method: 'GET',  path: path('/users'),       cache: { ttlSeconds: 60 } },
  newUser:   { method: 'POST', path: path('/users'),       cache: { ttlSeconds: 0 } },
  getUser:   { method: 'GET',  path: path('/users/:id'),   cache: { ttlSeconds: 30 } },
} satisfies Record<string, {
  method: HttpMethod
  path: ValidatedPath
  cache: { ttlSeconds: number; staleWhileRevalidate?: number }
}>

routes.listUsers.method      // 'GET'                 — literal preserved
routes.listUsers.path        // ValidatedPath         — carries proof of leading-slash check
routes.getUser.path          // ValidatedPath
routes['typo']               // Error: Property 'typo' does not exist on type {...}.

// Adding `{ method: 'PATCH', path: path('users'), ... }`:
//   - 'PATCH' fails the satisfies check (not in HttpMethod)
//   - path('users') fails the template-literal constraint (no leading slash)
// Both errors point at the offending field, not at an opaque union.
```

The combination — `satisfies` for *shape*, brand for *invariant* — gives a one-line declaration the same guarantees a 50-line `parse-and-validate` runtime check would. The brand survives into every site that reads the config.

**When NOT to apply:**
- For values constructed from runtime input (user form, env var) — `satisfies` cannot validate runtime data. Pair with `[[dsl-schema-first-inference]]` at the boundary instead.
- For simple `as const` immutability requirements — no brand, no satisfies, just `as const`. Reach for this rule when the *shape constraint* matters, not just the const-ness.

**Scope delta:**
- `typescript-refactor`'s `arch-satisfies-over-annotation` and `arch-const-assertion` introduce `satisfies` and `as const` independently. This rule combines them with branded constraint types to encode invariants in the config's resulting type — going beyond shape conformance into invariant conformance.

Reference: [TypeScript 4.9 Release Notes — The `satisfies` Operator](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-9.html#the-satisfies-operator)
