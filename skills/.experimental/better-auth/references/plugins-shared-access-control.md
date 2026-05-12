---
title: Define Access Control and Roles Once, Share Between Server and Client Plugins
impact: MEDIUM-HIGH
impactDescription: prevents permission drift between server-enforced and client-checked roles
tags: plugins, organization, admin, access-control
---

## Define Access Control and Roles Once, Share Between Server and Client Plugins

The `organization` and `admin` plugins each take an access controller (`ac`) and a set of named roles (`owner`, `admin`, `member`, etc.). The server uses these to enforce permission checks on every API call; the client uses the same definitions to gate UI ("if user has `member:read`, show this button"). Defining them twice — once on the server, once on the client — guarantees drift: roles get renamed in one place, permissions added in the other, and the UI shows actions the server then rejects. Always define `ac` + roles in a single shared module and import into both sides.

**Incorrect (separate role definitions diverge over time):**

```typescript
// lib/auth.ts (server)
import { organization } from "better-auth/plugins";
import { createAccessControl } from "better-auth/plugins/access";

const ac = createAccessControl({
  invoices: ["read", "write"],
  members: ["read", "invite", "remove"],
});
const admin = ac.newRole({ invoices: ["read", "write"], members: ["read", "invite"] });
const member = ac.newRole({ invoices: ["read"] });

export const auth = betterAuth({
  plugins: [organization({ ac, roles: { admin, member } })],
});
```

```typescript
// lib/auth-client.ts (client) — duplicated and already out of sync
import { organizationClient } from "better-auth/client/plugins";
import { createAccessControl } from "better-auth/plugins/access";

const ac = createAccessControl({
  invoices: ["read", "write"],
  members: ["read", "invite"], // ← missing "remove", added in server later
});
// ...
```

**Correct (single source of truth):**

```typescript
// lib/permissions.ts — imported by BOTH server auth and client auth
import { createAccessControl } from "better-auth/plugins/access";

export const ac = createAccessControl({
  invoices: ["read", "write", "delete"],
  members: ["read", "invite", "remove"],
});

export const owner = ac.newRole({
  invoices: ["read", "write", "delete"],
  members: ["read", "invite", "remove"],
});
export const admin = ac.newRole({
  invoices: ["read", "write"],
  members: ["read", "invite"],
});
export const member = ac.newRole({
  invoices: ["read"],
});
```

```typescript
// lib/auth.ts (server)
import { organization } from "better-auth/plugins";
import { ac, owner, admin, member } from "./permissions";

export const auth = betterAuth({
  plugins: [organization({ ac, roles: { owner, admin, member } })],
});
```

```typescript
// lib/auth-client.ts (client)
import { organizationClient } from "better-auth/client/plugins";
import { ac, owner, admin, member } from "./permissions";

export const authClient = createAuthClient({
  plugins: [organizationClient({ ac, roles: { owner, admin, member } })],
});
```

Reference: [Better Auth — Organization Plugin: Access Control](https://www.better-auth.com/docs/plugins/organization#access-control)
