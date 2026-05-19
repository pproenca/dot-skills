---
title: Use `const T` to Preserve Literals Through Overloaded APIs
impact: HIGH
impactDescription: eliminates 100% of widening losses at overload-heavy call sites; removes the need for `as const` at every call
tags: mod, const-type-parameters, overloads, inference, typescript-5
---

## Use `const T` to Preserve Literals Through Overloaded APIs

TypeScript 5.0's `const` type parameters tell the compiler to infer the *narrowest* type for a generic — string literals stay as their literals, arrays stay as tuples — without the caller writing `as const` at the call site. The standard rule is "use it for literal inference," which sells the feature short. The advanced application is in **overloaded APIs** and **higher-order combinators** where widening at one position cascades to wrong overload selection, wrong return types, and wrong autocomplete several layers down. This is the pattern Zod, Drizzle, and Hono use to keep literal types alive across their entire fluent surface.

**Incorrect (no `const` — caller must remember `as const` everywhere):**

```typescript
function route<Path extends string>(path: Path): { path: Path } { return { path } }

const r = route('/users')
//    ^? { path: string }    — widened. Subsequent param-extraction can't see the literal.

const r2 = route('/users' as const)
//    ^? { path: '/users' }  — works but requires discipline at every call.
```

**Correct (`const T` keeps the literal in inference):**

```typescript
function route<const Path extends string>(path: Path): { path: Path } { return { path } }

const r = route('/users')
//    ^? { path: '/users' }  — literal preserved automatically.

const r2 = route('/users/:id', { method: 'GET' as const })
//    ^? { path: '/users/:id' }
```

The depth payoff appears in overloaded fluent APIs where the literal at one call decides which overload fires at the next:

```typescript
type RouteMethods = 'GET' | 'POST'

function endpoint<const M extends RouteMethods>(method: M): Builder<M>
function endpoint(method: RouteMethods): Builder<RouteMethods>
function endpoint(method: RouteMethods): Builder<RouteMethods> { /* … */ return {} as any }

interface Builder<M extends RouteMethods> {
  // Different shapes per method:
  body: M extends 'POST' ? (schema: unknown) => Builder<M> : never
  handler: (h: M extends 'GET' ? () => Response : (body: unknown) => Response) => void
}

endpoint('POST').body(/* … */).handler(body => new Response())  // 'POST' selected
endpoint('GET').handler(() => new Response())                    // 'GET' selected; `body` is `never`
```

Without `const`, `'POST'` widens to `RouteMethods`, both branches resolve to `unknown`, and the user sees `never` everywhere.

Three places `const T` pays off most:
1. **Tuples passed positionally** — `const T extends readonly unknown[]` keeps positions and length alive.
2. **Path strings driving downstream inference** — see `[[dsl-route-param-inference]]`.
3. **Discriminator values in tagged unions** — keeps the discriminant narrowed for downstream conditional types.

**When NOT to apply:**
- Generic functions whose return doesn't depend on the literal value — `const` adds noise. Plain `T extends string` is fine.
- When the caller deliberately passes a *runtime* value (`route(req.path)`) — the literal-preservation request is silently ignored, but the noise remains.

**Scope delta:**
- `typescript-refactor`'s `modern-const-type-parameters` introduces `const T` as a literal-preservation feature. This rule is about the *overload-disambiguation* and *cascading-inference* use cases — the situations where forgetting `const` produces wrong overload selection, not just slightly widened types.

Reference: [TypeScript 5.0 Release Notes — `const` Type Parameters](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-0.html#const-type-parameters)
