---
title: Set HttpOnly, Secure, and SameSite on session cookies
tags: sec, cookies, session, xss
---

## Set HttpOnly, Secure, and SameSite on session cookies

The wrong default is emitting a bare `Set-Cookie: session=${token}`. Without `HttpOnly` any XSS reads the token; without `Secure` it travels over plaintext HTTP; without `SameSite` it rides along on cross-site requests. The Start authentication docs' own example uses all three plus the `__Host-` prefix, which additionally locks the cookie to the exact host and `Path=/`.

**Evidence of violation:** a `Set-Cookie` header construction (or cookie-helper call) for a session/auth token missing any of `HttpOnly`, `Secure`, or `SameSite`.

```ts
setResponseHeader(
  'Set-Cookie',
  `__Host-session=${token}; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=${60 * 60 * 24 * 7}`,
)
```

Reference: [TanStack Start — Authentication Server Primitives](https://tanstack.com/start/latest/docs/framework/react/guide/authentication-server-primitives)
