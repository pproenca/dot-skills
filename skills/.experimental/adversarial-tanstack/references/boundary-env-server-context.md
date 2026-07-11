---
title: Read process.env only inside server execution contexts
tags: boundary, env-vars, secrets, edge-runtime
---

## Read process.env only inside server execution contexts

The wrong default is reading `process.env` at module scope, a habit carried over from Node-only codebases. In a Start app that read is wrong on two axes at once: the bundler can inline the value into the client bundle (shipping the secret to every browser), and on Cloudflare Workers and other edge runtimes env is injected per-request, so module-level code runs before the env exists and the read evaluates to `undefined` even on the server.

**Evidence of violation:** a `process.env.X` reference at module top level, or in any code reachable from the client (component bodies, shared utilities) — anywhere outside a `.handler()`, a middleware `.server()` callback, a `server: { handlers }` block, or a `createServerOnlyFn` wrapper.

**Incorrect (module-scope read, inlined into the bundle and undefined on edge):**

```ts
// src/utils/stripe.functions.ts
import Stripe from 'stripe'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

export const createCheckout = createServerFn({ method: 'POST' })
  .handler(async () => stripe.checkout.sessions.create({ mode: 'payment' }))
```

**Correct (read inside the handler, where env exists per-request and never bundles client-side):**

```ts
// src/utils/stripe.functions.ts
import Stripe from 'stripe'

export const createCheckout = createServerFn({ method: 'POST' })
  .handler(async () => {
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)
    return stripe.checkout.sessions.create({ mode: 'payment' })
  })
```

Reference: [TanStack Start — Environment Variables](https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables), [Code Execution Patterns](https://tanstack.com/start/latest/docs/framework/react/guide/code-execution-patterns)
