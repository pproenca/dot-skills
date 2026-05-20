---
title: Declare a CSP Allowlist for the Widget
impact: HIGH
impactDescription: prevents silently blocked API and image calls
tags: sec, csp, allowlist, sandbox
---

## Declare a CSP Allowlist for the Widget

The widget runs under a restrictive sandbox Content Security Policy. Anything not declared in `_meta.ui.csp` — `connectDomains` for fetch/XHR/WebSocket, `resourceDomains` for images and fonts — is blocked, and the only signal is a console error the user never sees, so the widget renders empty or missing its imagery. Declare exactly the origins your component contacts and no more.

**Incorrect (no CSP; the sandbox blocks the map tiles and the widget renders empty):**

```typescript
return { contents: [{ uri, mimeType: "text/html;profile=mcp-app", text: html }] };
```

**Correct (declare exactly the origins the component talks to):**

```typescript
return { contents: [{ uri, mimeType: "text/html;profile=mcp-app", text: html, _meta: { ui: {
  csp: {
    connectDomains: ["https://api.transit.example.com"],
    resourceDomains: ["https://tiles.transit.example.com"],
  },
} } }] };
```

Keep the lists minimal — a broad allowlist both weakens security and draws extra review scrutiny.

Reference: [Build your MCP server – Apps SDK](https://developers.openai.com/apps-sdk/build/mcp-server)
