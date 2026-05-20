---
title: Set a Unique ui.domain for the Component
impact: HIGH
impactDescription: prevents submission blocking and origin clashes
tags: wire, domain, sandbox, submission
---

## Set a Unique ui.domain for the Component

Each app declares `_meta.ui.domain`, a dedicated origin the host uses to sandbox the widget — it renders under that domain's isolated sandbox host. The value must be unique per app and is required for directory submission; omitting it blocks the listing and can cause widgets from different apps to share an origin, which breaks storage isolation and CSP scoping.

**Incorrect (no domain; the host can't assign a sandbox origin and submission is blocked):**

```typescript
return { contents: [{ uri, mimeType: "text/html;profile=mcp-app", text: html }] };
```

**Correct (unique origin per app, declared on the resource):**

```typescript
return { contents: [{ uri, mimeType: "text/html;profile=mcp-app", text: html, _meta: { ui: {
  domain: "https://seatmap.flighty.example.com",
  prefersBorder: true,
} } }] };
```

`prefersBorder` is a separate rendering hint that asks the host to frame the widget as a bordered card; set it when the content reads better contained.

Reference: [Build your MCP server – Apps SDK](https://developers.openai.com/apps-sdk/build/mcp-server)
