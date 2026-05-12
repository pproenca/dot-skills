---
title: Never Wildcard trustedOrigins; List Origins Explicitly
impact: HIGH
impactDescription: prevents arbitrary cross-origin sites from initiating sign-in against your API
tags: security, trusted-origins, csrf
---

## Never Wildcard trustedOrigins; List Origins Explicitly

It's tempting under deadline pressure to set `trustedOrigins: ["*"]` to make CSRF errors go away — every guide warns against it, but the pattern persists because narrow-scope alternatives (per-environment lists, wildcard subdomains) are less obvious. A `"*"` literal bypasses Better Auth's CSRF defense entirely: any malicious page on any origin can submit a form against your auth API while a user is logged in. Use wildcard subdomain syntax (`https://*.example.com`) when you need flexibility, and review the list per release.

**Incorrect (wildcard origin):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  trustedOrigins: ["*"], // ← any site can CSRF-submit against this auth API
});
```

**Incorrect (user-controlled domains):**

```typescript
// Don't pull origins from a database row a user can edit
const tenantOrigin = await db.query.tenant.findFirst({ where: eq(tenant.id, tenantId) });
export const auth = betterAuth({
  trustedOrigins: [tenantOrigin.url], // ← attacker-controlled if they own a tenant
});
```

**Correct (explicit list, with subdomain wildcards for known-safe ranges):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  trustedOrigins: [
    "https://app.example.com",
    "https://admin.example.com",
    "https://*.preview.example.com",  // limited subdomain wildcard for previews
    ...(process.env.NODE_ENV !== "production"
      ? ["http://localhost:3000", "http://localhost:5173"]
      : []),
  ],
});
```

**Correct (dynamic — function-based check with allowlist):**

```typescript
export const auth = betterAuth({
  trustedOrigins: (request) => {
    const origin = request.headers.get("origin");
    if (!origin) return [];
    // Allow only origins that belong to verified tenants
    if (ALLOWED_TENANT_ORIGINS.has(origin)) return [origin];
    return [];
  },
});
```

**Warning:** The wildcard-subdomain syntax (`https://*.example.com`) is exact — it matches single-level subdomains only. It does NOT match `https://example.com` (the apex) or `https://a.b.example.com` (nested). Add both explicitly if needed.

Reference: [Better Auth — Security & trustedOrigins](https://www.better-auth.com/docs/reference/options#trustedorigins)
