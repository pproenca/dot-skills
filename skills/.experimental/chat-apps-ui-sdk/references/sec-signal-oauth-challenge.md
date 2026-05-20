---
title: Signal Auth With a www-authenticate Challenge
impact: MEDIUM-HIGH
impactDescription: prevents a broken widget on unauthenticated calls
tags: sec, oauth, www-authenticate, auth
---

## Signal Auth With a www-authenticate Challenge

When a tool needs the user to sign in, return the RFC 7235 challenge in `_meta["mcp/www_authenticate"]` so the host can run its own OAuth flow. Rendering an error widget or a custom login form instead leaves the user stuck — the sandbox cannot complete a real authentication flow, and the host has no way to know sign-in is required.

**Incorrect (renders an error the sandbox can't turn into a real login):**

```typescript
return { structuredContent: { error: "Please log in to view orders" } };
```

**Correct (return the standard challenge so the host runs its OAuth flow):**

```typescript
return {
  content: [{ type: "text", text: "Sign in to continue." }],
  _meta: { "mcp/www_authenticate": 'Bearer realm="orders", error="invalid_token"' },
};
```

The challenge is only half the flow: the host starts sign-in when the tool also declares per-tool `securitySchemes` metadata and the server exposes `/.well-known/oauth-protected-resource`. Ship both halves, not just the runtime error.

Reference: [Reference – Apps SDK](https://developers.openai.com/apps-sdk/reference)
