---
title: Use the Node.js Runtime for Middleware That Calls auth.api
impact: CRITICAL
impactDescription: prevents Edge Runtime crashes from database adapter incompatibility
tags: route, middleware, next-js, edge-runtime, node-runtime
---

## Use the Node.js Runtime for Middleware That Calls auth.api

Next.js middleware defaults to the Edge Runtime, which doesn't support most database drivers (`pg`, `mysql2`, `mongodb`, Prisma's binary engine). If your middleware calls `auth.api.getSession({ headers })` — which queries the database — it crashes at build or first invocation. Two valid patterns: (1) opt the middleware into the Node.js runtime (Next 15.2+); or (2) use the Edge-safe cookie-only check via `getSessionCookie()` for routing, then do the full session lookup in the route handler.

**Incorrect (database call in default Edge middleware):**

```typescript
// middleware.ts — runs on Edge by default
import { NextRequest, NextResponse } from "next/server";
import { headers } from "next/headers";
import { auth } from "@/lib/auth";

export async function middleware(req: NextRequest) {
  const session = await auth.api.getSession({ headers: await headers() });
  // ↑ crashes on Edge: pg / prisma can't run here
  if (!session) return NextResponse.redirect(new URL("/sign-in", req.url));
  return NextResponse.next();
}
```

**Correct (opt into Node.js runtime — Next 15.2+):**

```typescript
// middleware.ts
import { NextRequest, NextResponse } from "next/server";
import { headers } from "next/headers";
import { auth } from "@/lib/auth";

export async function middleware(req: NextRequest) {
  const session = await auth.api.getSession({ headers: await headers() });
  if (!session) return NextResponse.redirect(new URL("/sign-in", req.url));
  return NextResponse.next();
}

export const config = {
  runtime: "nodejs",           // ← required for auth.api calls
  matcher: ["/dashboard/:path*"],
};
```

**Alternative (Edge-safe cookie check + per-page server validation):**

```typescript
// middleware.ts — stays on Edge, only checks cookie presence
import { NextRequest, NextResponse } from "next/server";
import { getSessionCookie } from "better-auth/cookies";

export async function middleware(req: NextRequest) {
  const sessionCookie = getSessionCookie(req);
  if (!sessionCookie) return NextResponse.redirect(new URL("/sign-in", req.url));
  return NextResponse.next();
}

export const config = { matcher: ["/dashboard/:path*"] };
```

```typescript
// app/dashboard/page.tsx — does the real session validation
import { auth } from "@/lib/auth";
import { headers } from "next/headers";
import { redirect } from "next/navigation";

export default async function Dashboard() {
  const session = await auth.api.getSession({ headers: await headers() });
  if (!session) redirect("/sign-in");
  return <h1>Welcome {session.user.name}</h1>;
}
```

**When to prefer which:** Edge + cookie check is faster at the edge but a stale cookie evades the check until the server page revalidates. Node middleware does the real check but adds DB latency to every protected route.

Reference: [Better Auth — Next.js: Middleware](https://www.better-auth.com/docs/integrations/next#middleware)
