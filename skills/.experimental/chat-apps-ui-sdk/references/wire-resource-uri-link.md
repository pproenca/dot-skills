---
title: Link Each Tool to Its UI With resourceUri
impact: CRITICAL
impactDescription: prevents tools that never render a widget
tags: wire, resource-uri, mcp-apps, metadata
---

## Link Each Tool to Its UI With resourceUri

A tool renders a component only when its descriptor carries `_meta.ui.resourceUri` pointing at a registered UI resource. This is the standard MCP Apps key; ChatGPT also accepts the alias `openai/outputTemplate`, which maps to the same thing. Omit it and the tool returns text with no widget, every single time — there is no implicit linkage between a tool and a component.

**Incorrect (no UI link; the tool result renders as plain text):**

```typescript
server.registerTool("show_seatmap", { inputSchema: { flightId: z.string() } }, getSeatmap);
```

**Correct (standard key links the tool to its component; alias kept for ChatGPT back-compat):**

```typescript
server.registerTool("show_seatmap", {
  inputSchema: { flightId: z.string() },
  _meta: {
    ui: { resourceUri: "ui://seatmap/v2.html" },     // MCP Apps standard
    "openai/outputTemplate": "ui://seatmap/v2.html",  // additive ChatGPT alias
  },
}, getSeatmap);
```

Prefer the standard `ui.resourceUri` so the same server renders across hosts (see [[dist-build-on-mcp-apps-standard]]); treat the `openai/` alias as additive, not primary.

Reference: [MCP Apps – Bringing UI to MCP clients](https://blog.modelcontextprotocol.io/posts/2026-01-26-mcp-apps/)
