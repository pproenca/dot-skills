---
title: Use auth.api.getSession on the Server, authClient.useSession on the Client
impact: HIGH
impactDescription: prevents always-null session in server components and stale data in client UI
tags: session, server, client, react, next-js
---

## Use auth.api.getSession on the Server, authClient.useSession on the Client

Better Auth exposes two parallel session APIs and they're not interchangeable. `auth.api.getSession({ headers })` reads the session cookie from the request headers and runs server-side — required in server components, server actions, route handlers, and middleware. `authClient.useSession()` (and `authClient.getSession()`) is a fetch-driven reactive hook that runs in the browser — required for any UI that updates when the user signs in or out. Mixing them produces null sessions in server components (because `authClient` has no request headers) or stale UI on the client (because `auth.api` doesn't react to sign-out events).

**Incorrect (using authClient on the server):**

```typescript
// app/dashboard/page.tsx — Server Component
import { authClient } from "@/lib/auth-client";

export default async function Dashboard() {
  const session = await authClient.getSession(); // ← no headers; returns null
  if (!session.data) redirect("/sign-in");
  return <h1>Hello {session.data.user.name}</h1>;
}
```

**Correct (server uses auth.api.getSession with headers):**

```typescript
// app/dashboard/page.tsx — Server Component
import { auth } from "@/lib/auth";
import { headers } from "next/headers";
import { redirect } from "next/navigation";

export default async function Dashboard() {
  const session = await auth.api.getSession({ headers: await headers() });
  if (!session) redirect("/sign-in");
  return <h1>Hello {session.user.name}</h1>;
}
```

**Correct (client UI uses useSession for reactivity):**

```typescript
// components/UserMenu.tsx — Client Component
"use client";
import { authClient } from "@/lib/auth-client";

export function UserMenu() {
  const { data: session, isPending } = authClient.useSession();
  if (isPending) return <Skeleton />;
  if (!session) return <SignInButton />;
  return (
    <button onClick={() => authClient.signOut()}>
      Sign out {session.user.name}
    </button>
  );
}
```

**When to also use server-side in client paths:** For the initial render of a client component on the server, pass the session as a prop from the server component above it — avoids the loading flicker `useSession` produces before the first fetch resolves.

Reference: [Better Auth — Session Management](https://www.better-auth.com/docs/concepts/session-management)
