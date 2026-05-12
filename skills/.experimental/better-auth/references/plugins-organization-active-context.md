---
title: Set the Active Organization on Session, Don't Pass It Per-Request
impact: MEDIUM
impactDescription: prevents inconsistent active-org state across tabs and stale auth checks
tags: plugins, organization, session, context
---

## Set the Active Organization on Session, Don't Pass It Per-Request

In multi-tenant apps using the `organization` plugin, every request needs to know "which org is the user acting as?" The wrong pattern is to pass `?orgId=...` from the URL or sniff a cookie in every API handler — it drifts across tabs (user switches org in one tab, the other still acts as the old one) and exposes the org context to the wire on every request. The right pattern is to set the active organization on the session via `authClient.organization.setActive` (or server-side `auth.api.setActiveOrganization`); Better Auth then attaches `session.activeOrganizationId` automatically.

**Incorrect (org ID in every URL):**

```typescript
// pages routes scattered with orgId param
GET  /api/orgs/:orgId/invoices
POST /api/orgs/:orgId/members

// server handler — every endpoint must re-verify membership
const member = await db.query.member.findFirst({
  where: and(eq(member.userId, session.user.id), eq(member.organizationId, req.params.orgId)),
});
if (!member) throw new ForbiddenError();
// → duplicated check in every endpoint, drift on switch
```

**Correct (active org on session):**

```typescript
// client: user clicks "Switch to Acme" in the org picker
await authClient.organization.setActive({ organizationId: "acme-123" });
// session is updated server-side; cookies and useSession both reflect the change
```

```typescript
// server endpoint — single source of truth
import { auth } from "@/lib/auth";
import { headers } from "next/headers";

export async function GET(req: Request) {
  const session = await auth.api.getSession({ headers: await headers() });
  if (!session?.session.activeOrganizationId) {
    return new Response("No active organization", { status: 403 });
  }
  const orgId = session.session.activeOrganizationId; // typed, server-trusted
  return Response.json(await db.query.invoices.findMany({ where: eq(invoices.organizationId, orgId) }));
}
```

**Common use cases:**
- Pair with `customSession` to also project the active org's role/permissions onto the session response in a single round trip.
- Use a database hook on session `update` to broadcast org-switch events to other devices (WebSocket / SSE).

**Warning:** `setActiveOrganization` invalidates the cookie cache for that session — adjacent tabs will see the change on next request, but websocket-driven UI may need to refetch session manually.

Reference: [Better Auth — Organization Plugin](https://www.better-auth.com/docs/plugins/organization)
