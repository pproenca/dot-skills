---
title: Enforce Authorization on the Server
impact: HIGH
impactDescription: prevents spoofed client-hint access
tags: sec, auth, authorization, server
---

## Enforce Authorization on the Server

Client-supplied hints like `openai/userAgent`, `openai/locale`, and coarse `openai/userLocation` are conveniences for personalization, not credentials — they are trivially forged by anything that can post to your server. Make every authorization decision inside the MCP server and its backing API against a verified session or OAuth token, never by trusting a value the iframe or host passed in.

**Incorrect (trusts a forgeable client hint to grant privileged access):**

```typescript
if (meta["openai/userAgent"]?.includes("Internal")) return adminReport(); // spoofable
```

**Correct (authorize from a verified token on the server):**

```typescript
const session = await verifySession(req); // throws on invalid or expired token
if (!session.roles.includes("admin")) throw new Error("forbidden");
return adminReport(session.userId);
```

Reference: [Build your MCP server – Apps SDK](https://developers.openai.com/apps-sdk/build/mcp-server)
