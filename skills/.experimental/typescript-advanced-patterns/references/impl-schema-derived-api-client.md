---
title: Derive Client Argument and Return Types from Endpoint Schemas
impact: MEDIUM-HIGH
impactDescription: eliminates 100% of input/output drift between client and server; prevents serialisation mismatches
tags: impl, api-client, schema, inference, end-to-end-types
---

## Derive Client Argument and Return Types from Endpoint Schemas

A handwritten API client is a parallel definition of the server's contract — every endpoint change requires synchronised edits on two sides, and the sync goes wrong constantly. The end-to-end type pattern (used by tRPC, Hono RPC, oRPC, ts-rest) flips the polarity: define each endpoint's input and output as schemas once, derive both the server route handler's parameter types and the client's call signature from the same source. Wrong arguments fail at the client's compile step; wrong responses fail at the server's compile step.

**Incorrect (parallel definitions on client and server drift):**

```typescript
// server/routes/users.ts
app.post('/users', (req, res) => {
  const { email, name } = req.body  // any
  /* … */
  res.json({ id: 'u_1', email, name })
})

// client/users.ts
async function createUser(input: { email: string; name: string }): Promise<{ id: string; email: string; name: string }> {
  const r = await fetch('/users', { method: 'POST', body: JSON.stringify(input) })
  return r.json()
}

// Server adds a required `tenantId` field. Client compiles. Production 400s start flowing.
```

**Correct (single schema drives both ends):**

```typescript
// shared/routes.ts — the source of truth, imported by both server and client
import { z } from 'zod'

export const routes = {
  createUser: {
    method: 'POST',
    path: '/users',
    input:  z.object({ email: z.string().email(), name: z.string().min(1), tenantId: z.string() }),
    output: z.object({ id: z.string(), email: z.string(), name: z.string(), tenantId: z.string(), createdAt: z.string().pipe(z.coerce.date()) }),
  },
} as const

// server/index.ts — handler typed by the schema
import { routes } from '../shared/routes'

app.post(routes.createUser.path, async (req, res) => {
  const input = routes.createUser.input.parse(req.body)
  // input: { email: string; name: string; tenantId: string }
  const created = await db.users.insert(input)
  res.json(routes.createUser.output.parse(created))
})

// client/index.ts — client signature derived from the same schemas
import { routes } from '../shared/routes'

type ClientFor<R extends { input: z.ZodTypeAny; output: z.ZodTypeAny }> =
  (input: z.input<R['input']>) => Promise<z.output<R['output']>>

const client: { [K in keyof typeof routes]: ClientFor<(typeof routes)[K]> } = {
  createUser: async (input) => {
    const validated = routes.createUser.input.parse(input)
    const r = await fetch(routes.createUser.path, { method: routes.createUser.method, body: JSON.stringify(validated) })
    return routes.createUser.output.parse(await r.json())
  },
}

// Usage:
await client.createUser({ email: 'a@b.c', name: 'Ada', tenantId: 't_1' })  // OK
await client.createUser({ email: 'a@b.c', name: 'Ada' })                   // Error: missing tenantId
```

The server schema change *immediately* fails the client compile because the input type widened. No coordination, no drift.

Three design rules:

1. **Schemas live in a `shared/` package** importable by both client and server. Don't put them in `server/` and re-export — the client should depend on the schemas directly, not on the server.
2. **Parse on the way in *and* on the way out.** Server parses the request body and the response. Client parses the request input and the response. Two-way parsing catches both directions of drift.
3. **Use `z.input` for request shapes and `z.output` for response shapes.** Transforms (coercions, defaults) make these different types; treating them as one is the most common end-to-end-types bug.

**When NOT to apply:**
- Public APIs consumed by clients you don't control — schema-sharing requires both ends to use the same language and tooling. Ship OpenAPI/JSON Schema instead, or generate code from it.
- Stable, simple endpoints that rarely change — the schema overhead doesn't pay for itself.

**Scope delta:**
- Combines `[[dsl-schema-first-inference]]` (schema as source of types) with the *bilateral* discipline that makes end-to-end typing actually catch drift on both sides.

Reference: [tRPC — Quickstart](https://trpc.io/docs/quickstart)
