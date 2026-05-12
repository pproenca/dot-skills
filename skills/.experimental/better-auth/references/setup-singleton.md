---
title: Export a Single Auth Instance from a Server-Only Module
impact: CRITICAL
impactDescription: prevents duplicate database connections, type drift, and leaked secrets
tags: setup, singleton, server-only, security
---

## Export a Single Auth Instance from a Server-Only Module

`betterAuth(...)` allocates database adapter resources and reads secrets at construction time. Creating a new instance per request exhausts connection pools and recompiles plugin schemas; constructing it in a file that is imported by client code leaks `BETTER_AUTH_SECRET` into the bundle. The canonical pattern is one server-only module (`lib/auth.ts`) that exports a singleton, imported by route handlers, server actions, and server components only.

**Incorrect (per-request construction or shared client/server file):**

```typescript
// app/api/auth/[...all]/route.ts
import { betterAuth } from "better-auth";
import { db } from "@/db";

export async function POST(req: Request) {
  const auth = betterAuth({ database: db, /* ... */ }); // new instance every request
  return auth.handler(req);
}
```

```typescript
// lib/auth.ts — imported by both client and server (leaks secret to bundle)
import { betterAuth } from "better-auth";
export const auth = betterAuth({ secret: process.env.BETTER_AUTH_SECRET, /* ... */ });
export { auth as authForClientToo }; // ← imported by a client component
```

**Correct (one server-only singleton):**

```typescript
// lib/auth.ts  ← server-only; never import from a client component
import { betterAuth } from "better-auth";
import { db } from "@/db";

export const auth = betterAuth({
  database: db,
  emailAndPassword: { enabled: true },
  // ...
});
```

```typescript
// app/api/auth/[...all]/route.ts
import { auth } from "@/lib/auth";
import { toNextJsHandler } from "better-auth/next-js";

export const { GET, POST } = toNextJsHandler(auth);
```

**Implementation:** In Next.js, add `import "server-only";` at the top of `lib/auth.ts` so a stray client import becomes a build error. In Node/Express, keep `auth.ts` outside any directory bundled for the browser.

Reference: [Better Auth — Installation: Create Auth Instance](https://www.better-auth.com/docs/installation#create-a-better-auth-instance)
