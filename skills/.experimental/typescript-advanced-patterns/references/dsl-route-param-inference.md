---
title: Infer Route Parameters from Path Patterns
impact: CRITICAL
impactDescription: prevents 100% of param-name drift between route declarations and handlers
tags: dsl, routing, template-literals, infer, library-design
---

## Infer Route Parameters from Path Patterns

Router APIs that take a path string (`/users/:id/posts/:postId`) and a handler are everywhere — Express, Hono, Next.js. Without inference, the handler receives `params: Record<string, string>`, and a route rename leaves stale property accesses scattered across the codebase. Inferring the param object from the route literal — using template-literal `infer` to extract `:name` segments — means renaming the route causes the handler to flag every site that still references the old name.

**Incorrect (params is a string record):**

```typescript
type Handler = (params: Record<string, string>) => Response

function route(path: string, handler: Handler) { /* ... */ }

route('/users/:userId/posts/:postId', (params) => {
  const id = params.userId        // string | undefined at best, never refactor-safe
  const postId = params.postID    // Typo. Returns undefined. Crashes downstream.
  return new Response(id ?? postId)
})
```

**Correct (params shape inferred from the path literal):**

```typescript
type ExtractParams<Path extends string> =
  Path extends `${string}:${infer Param}/${infer Rest}`
    ? { [K in Param | keyof ExtractParams<`/${Rest}`>]: string }
    : Path extends `${string}:${infer Param}`
    ? { [K in Param]: string }
    : Record<string, never>

function route<P extends string>(path: P, handler: (params: ExtractParams<P>) => Response) {
  /* ... */
}

route('/users/:userId/posts/:postId', (params) => {
  const id = params.userId        // string
  const postId = params.postId    // string
  const wrong = params.postID     // Error: Property 'postID' does not exist
  return new Response(`${id}/${postId}`)
})
```

When the route literal changes from `:userId` to `:authorId`, every handler that still destructures `userId` reports a type error. This is how libraries like Hono and TanStack Router achieve compile-time route safety.

**When NOT to apply:**
- Routes built at runtime from user input or remote config — the path is `string`, not a literal type, and inference cannot run.
- Wildcard or regex segments (`*`, `:id(\\d+)`) — the simple parser above does not handle them; either skip those routes or extend the parser with additional template-literal cases.

**Scope delta:**
- Companion rule to `[[dsl-type-safe-object-paths]]` — both rely on template-literal `infer` to parse string structure, but solve different DSL problems.

Reference: [TypeScript Handbook — Inference in Conditional Types](https://www.typescriptlang.org/docs/handbook/2/conditional-types.html#inferring-within-conditional-types)
