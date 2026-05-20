---
title: Never Embed Secrets in Bundles or Payloads
impact: HIGH
impactDescription: prevents key exposure to end users
tags: sec, secrets, api-keys, payload
---

## Never Embed Secrets in Bundles or Payloads

`structuredContent`, `content`, `_meta`, widget state, and the inlined bundle are all delivered to the user's browser. An API key baked into the component or returned in a payload is readable by anyone who opens devtools, and a leaked live key is an incident. Keep secrets on the server and have the widget reach third-party APIs only by calling your own authenticated tool, which uses the key server-side.

**Incorrect (key shipped to the browser inside the bundle and the payload):**

```typescript
const html = `<script>const MAPS_KEY="AIzaSyA8_live_…";</script>${bundle}`;
return { structuredContent: { ok: true }, _meta: { stripeKey: "sk_live_51H…" } };
```

**Correct (secrets stay server-side; the widget calls your tool, which holds the key):**

```typescript
const html = `<div id="root"></div><script type="module">${bundle}</script>`; // no secrets inlined
return { structuredContent: { ok: true } }; // widget calls back through an authenticated tool
```

Reference: [Build your MCP server – Apps SDK](https://developers.openai.com/apps-sdk/build/mcp-server)
