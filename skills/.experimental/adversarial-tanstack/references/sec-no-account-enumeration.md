---
title: Keep auth endpoints silent about account existence
tags: sec, enumeration, timing, password-reset
---

## Keep auth endpoints silent about account existence

The wrong default in login and password-reset handlers is branching observable behavior on whether the account exists — returning 200 vs 404, "email sent" vs "no account with that email", or short-circuiting before the expensive hash compare when the lookup misses (a timing leak). Each variant lets an attacker enumerate which emails have accounts. The Start docs list all three as explicit do-nots.

**Evidence of violation:** a login/registration/password-reset handler whose response status, message, or work performed differs based on the result of the user lookup.

**Incorrect (response reveals which emails are registered):**

```ts
export const requestPasswordReset = createServerFn({ method: 'POST' })
  .validator(z.object({ email: z.string().email() }))
  .handler(async ({ data }) => {
    const user = await db.users.findByEmail(data.email)
    if (!user) return { status: 404, message: 'No account with that email' }
    await sendResetEmail(user)
    return { status: 200, message: 'Reset email sent' }
  })
```

**Correct (identical response and comparable work on both paths):**

```ts
export const requestPasswordReset = createServerFn({ method: 'POST' })
  .validator(z.object({ email: z.string().email() }))
  .handler(async ({ data }) => {
    const user = await db.users.findByEmail(data.email)
    if (user) await sendResetEmail(user)
    return { message: 'If that email has an account, a reset link is on its way.' }
  })
```

Reference: [TanStack Start — Authentication Server Primitives](https://tanstack.com/start/latest/docs/framework/react/guide/authentication-server-primitives)
