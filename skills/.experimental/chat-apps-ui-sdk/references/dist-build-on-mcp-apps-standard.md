---
title: Build on the Shared MCP Apps Standard
impact: MEDIUM
impactDescription: enables one server across multiple hosts
tags: dist, mcp-apps, portability, standard
---

## Build on the Shared MCP Apps Standard

The standard MCP Apps keys — `_meta.ui.resourceUri` and the JSON-RPC `ui/*` bridge — render from one server in Claude, ChatGPT, VS Code, and Goose. Building only on a single vendor's surface (reading data exclusively through `window.openai`, linking UI only with `openai/outputTemplate`) locks the app to one host. Treat the `openai/*` fields and `window.openai` extensions as additive enhancements behind capability checks, not as the foundation.

**Incorrect (ChatGPT-only keys; the widget renders nowhere else):**

```typescript
server.registerTool("show_board", { _meta: { "openai/outputTemplate": "ui://board/v1.html" } }, getBoard);
```

**Correct (standard key first; vendor extras layered on):**

```typescript
server.registerTool("show_board", { _meta: {
  ui: { resourceUri: "ui://board/v1.html" },     // renders in Claude, ChatGPT, VS Code, Goose
  "openai/outputTemplate": "ui://board/v1.html",  // additive ChatGPT alias
} }, getBoard);
```

Reference: [MCP Apps – Bringing UI to MCP clients](https://blog.modelcontextprotocol.io/posts/2026-01-26-mcp-apps/)
