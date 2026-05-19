---
title: Track Capabilities at the Type Level with Phantom Brands
impact: HIGH
impactDescription: enables compile-time "you must do X before Y" enforcement; prevents 100% of unauthorised-use bugs at the type layer
tags: mod, phantom-types, capabilities, brands, security
---

## Track Capabilities at the Type Level with Phantom Brands

Branded types are usually presented as a way to distinguish IDs. The advanced application is *capability tracking* — using brands to record what has been done to a value, so downstream functions can require evidence of those operations. `Validated<T>`, `Authenticated<User>`, `Sanitised<string>`, `Permitted<Request, 'admin'>` — each is a phantom marker that costs zero runtime and turns "did we remember to call validate?" into a compile error. This is how libraries like Effect track effects in the type system and how authorisation frameworks enforce role checks structurally.

**Incorrect (capability lives in runtime state — easy to skip):**

```typescript
function login(req: Request): { user: User; isAdmin: boolean } {
  const user = authenticate(req)
  return { user, isAdmin: user.role === 'admin' }
}

function deleteAccount(target: string, isAdmin: boolean) {
  if (!isAdmin) throw new Error('Forbidden')
  /* … destructive operation … */
}

// Anywhere downstream, the boolean can be forgotten or hardcoded.
deleteAccount('u_42', true) // compiles, "true" passed without any check having run.
```

**Correct (capability is a phantom brand carried by the type):**

```typescript
declare const __brand: unique symbol
type Branded<T, B> = T & { readonly [__brand]: B }

type Authenticated<U> = Branded<U, 'Authenticated'>
type Admin<U>         = Branded<U, 'Admin'>

function authenticate(req: Request): Authenticated<User> {
  /* verify token, etc. */
  return req.user as Authenticated<User>  // tag created at the boundary, only here
}

function requireAdmin(u: Authenticated<User>): Admin<User> {
  if (u.role !== 'admin') throw new Error('Forbidden')
  return u as Admin<User>
}

function deleteAccount(target: string, actor: Admin<User>) {
  /* … destructive operation … */
}

// Usage:
const auth  = authenticate(req)           // Authenticated<User>
const admin = requireAdmin(auth)           // Admin<User>
deleteAccount('u_42', admin)               // OK

deleteAccount('u_42', auth)                // Error: Authenticated<User> is not assignable to Admin<User>
deleteAccount('u_42', req.user as User)    // Error: User is not assignable to Admin<User>
```

The brand is a *phantom* — there is no `[__brand]` property at runtime, just a type-level tag. The only way to manufacture an `Admin<User>` is to go through `requireAdmin`, which encapsulates the check. Skipping the check requires explicit `as` and shows up immediately in code review.

Compose brands for multiple capabilities at once:

```typescript
type CsrfChecked = { readonly __csrf: 'checked' }
type RateLimited = { readonly __rate: 'limited' }

function handleRequest(
  req: Request & Authenticated<User> & CsrfChecked & RateLimited,
) { /* … */ }
```

The handler now refuses to be called unless every check has been applied to the same value.

**When NOT to apply:**
- When the capability check is genuinely runtime-only (user input, external state) and there's no boundary function that can stamp the brand — the brand reduces to documentation.
- For deeply branching control flow where the brand must be added and removed in nested ways. Effect-style monadic effect tracking handles that case better; phantom brands are best for *linear* "first do A, then do B" pipelines.

**Scope delta:**
- `typescript-refactor`'s `arch-branded-types` covers branded **IDs**. This rule covers branded **capabilities** — same nominal-typing mechanism, applied to the question "what has been done to this value?" rather than "what kind of value is this?"

Reference: [TypeScript Playground — Nominal Typing](https://www.typescriptlang.org/play/typescript/language-extensions/nominal-typing.ts.html)
