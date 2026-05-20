---
title: Validate postMessage Source in the Host
impact: HIGH
impactDescription: prevents spoofed bridge messages
tags: bridge, postmessage, origin, security
---

## Validate postMessage Source in the Host

When you implement the host side of the bridge with raw `postMessage` instead of the SDK, an unguarded listener accepts messages from any frame on the page. A malicious embed could then post a forged `tools/call` envelope and drive your tools. Verify that the message came from the widget iframe and accept only the JSON-RPC methods you expect before dispatching.

**Incorrect (accepts messages from any frame; a hostile embed can drive tool calls):**

```tsx
window.addEventListener("message", (e) => handleRpc(e.data));
```

**Correct (verify the sender is the widget iframe and allowlist methods):**

```tsx
window.addEventListener("message", (e) => {
  if (e.source !== widgetFrame.contentWindow) return;          // must be our iframe
  const msg = e.data;
  if (msg?.jsonrpc !== "2.0" || !ALLOWED_METHODS.has(msg.method)) return; // known methods only
  handleRpc(msg);
});
```

Prefer the official `App` / `AppRenderer` bridge, which performs this validation for you; hand-rolled listeners are where origin checks get forgotten.

Reference: [MCP Apps – Bringing UI to MCP clients](https://blog.modelcontextprotocol.io/posts/2026-01-26-mcp-apps/)
