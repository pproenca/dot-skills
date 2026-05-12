---
title: Use databaseHooks for Cross-Cutting Logic, Not Application-Layer Wrappers
impact: HIGH
impactDescription: prevents missed paths when auth events are triggered by plugins or background jobs
tags: db, hooks, lifecycle, plugins
---

## Use databaseHooks for Cross-Cutting Logic, Not Application-Layer Wrappers

When you need to run logic on every user creation (provision a Stripe customer, send a welcome email, mirror to an analytics service) the obvious instinct is to wrap your sign-up route handler. But Better Auth creates users from multiple paths: email sign-up, OAuth callbacks, passwordless email, anonymous → permanent upgrade, admin-created users, and plugin-driven flows. Wrapping one route misses the others. `databaseHooks` runs at the data-layer boundary, capturing every path uniformly.

**Incorrect (wrapping only the explicit sign-up route):**

```typescript
// app/api/sign-up/route.ts — wraps only this one path
export async function POST(req: Request) {
  const result = await auth.handler(req);
  if (result.ok) {
    await provisionStripeCustomer(/* ... */); // ← skipped on OAuth, passwordless email, etc.
  }
  return result;
}
```

**Correct (databaseHooks runs for every creation path):**

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";
import { stripe } from "@/lib/stripe";

export const auth = betterAuth({
  databaseHooks: {
    user: {
      create: {
        before: async (user) => {
          // Normalize data before insert
          return {
            data: {
              ...user,
              firstName: user.name?.split(" ")[0],
              lastName: user.name?.split(" ").slice(1).join(" "),
            },
          };
        },
        after: async (user) => {
          // Runs for ALL creation paths: email/password, OAuth, passwordless email, admin-created
          const customer = await stripe.customers.create({
            email: user.email,
            name: user.name,
          });
          await db.update(users).set({ stripeCustomerId: customer.id }).where(eq(users.id, user.id));
        },
      },
      update: {
        before: async (data, ctx) => {
          // ctx.context.session is the actor doing the update
          if (ctx.context.session) {
            await audit.log({ actor: ctx.context.session.userId, action: "user.update", data });
          }
          return { data };
        },
      },
    },
    session: { /* session lifecycle hooks */ },
    account: { /* OAuth account link/unlink hooks */ },
  },
});
```

**Warning:** Throwing inside a `before` hook cancels the operation; throwing inside an `after` hook leaves the user/session created and the side effect failed. Wrap `after` hooks in try/catch + retry queue for at-least-once delivery semantics.

Reference: [Better Auth — Database Hooks](https://www.better-auth.com/docs/concepts/database#database-hooks)
