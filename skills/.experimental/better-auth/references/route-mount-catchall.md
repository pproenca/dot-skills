---
title: Mount the Catch-All Handler at /api/auth/[...all] (or Framework Equivalent)
impact: CRITICAL
impactDescription: prevents 404 on every sign-in, OAuth callback, and session request
tags: route, handler, catch-all, framework
---

## Mount the Catch-All Handler at /api/auth/[...all] (or Framework Equivalent)

Better Auth exposes its entire API surface — sign-in, sign-up, OAuth callbacks, session, verification — under a single base path that defaults to `/api/auth`. Your framework's route file must catch every sub-path beneath it and forward to `auth.handler(req)` (or the framework-specific helper). Mounting it at `/api/auth` only (no catch-all) returns 404 for `/api/auth/sign-in/social`; using a different prefix means OAuth callback URLs registered with Google/GitHub never resolve.

**Incorrect (Next.js App Router with non-catchall route):**

```text
app/
└── api/
    └── auth/
        └── route.ts   ← only matches /api/auth, not /api/auth/sign-in, /api/auth/callback/google, ...
```

**Correct (Next.js App Router catch-all):**

```typescript
// app/api/auth/[...all]/route.ts
import { auth } from "@/lib/auth";
import { toNextJsHandler } from "better-auth/next-js";

export const { GET, POST } = toNextJsHandler(auth);
```

**Correct (Next.js Pages Router):**

```typescript
// pages/api/auth/[...all].ts
import { auth } from "@/lib/auth";
import { toNodeHandler } from "better-auth/node";

export default toNodeHandler(auth);

// Disable Next's body parsing — Better Auth reads the raw request
export const config = { api: { bodyParser: false } };
```

**Correct (SvelteKit):**

```typescript
// src/routes/api/auth/[...all]/+server.ts
import { auth } from "$lib/auth";
import { svelteKitHandler } from "better-auth/svelte-kit";
import { building } from "$app/environment";

export async function handle({ event, resolve }) {
  return svelteKitHandler({ event, resolve, auth, building });
}
```

**Correct (Hono / Bun / Node native):**

```typescript
import { Hono } from "hono";
import { auth } from "./auth";

const app = new Hono();
app.on(["GET", "POST"], "/api/auth/*", (c) => auth.handler(c.req.raw));
```

```typescript
// Express
import express from "express";
import { toNodeHandler } from "better-auth/node";

const app = express();
app.all("/api/auth/*", toNodeHandler(auth));
// IMPORTANT: mount BEFORE express.json() or auth handler can't read the body
```

**Warning (Express + body parsers):** Mount `auth` BEFORE `express.json()` / `express.urlencoded()`. Once those parsers consume the request body, the auth handler reads an empty stream and POSTs return 400.

Reference: [Better Auth — Integrations](https://www.better-auth.com/docs/integrations/next)
