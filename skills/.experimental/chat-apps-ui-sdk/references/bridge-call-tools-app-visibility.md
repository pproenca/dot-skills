---
title: Expose Tools to the App Before Calling Them
impact: HIGH
impactDescription: prevents rejected callTool requests
tags: bridge, call-tool, visibility, mcp
---

## Expose Tools to the App Before Calling Them

A widget can invoke server tools with `window.openai.callTool` (the JSON-RPC `tools/call` request), but only if the tool's descriptor allows app callers. The standard control is `_meta.ui.visibility` including `"app"`; ChatGPT also honors `openai/widgetAccessible: true`. Call a model-only tool from the iframe and the host rejects it — the click appears to do nothing because the rejection never surfaces in the UI.

**Incorrect (tool is model-only; the widget's callTool is rejected):**

```typescript
server.registerTool("filter_seats", { inputSchema: { onlyWindow: z.boolean() } }, filterSeats);
// inside the component:
window.openai.callTool("filter_seats", { onlyWindow: true }); // rejected: not app-callable
```

**Correct (mark the tool app-callable, then invoke it from the widget):**

```typescript
server.registerTool("filter_seats", {
  inputSchema: { onlyWindow: z.boolean() },
  _meta: { ui: { visibility: ["model", "app"] } }, // app callers allowed
}, filterSeats);
window.openai.callTool("filter_seats", { onlyWindow: true });
```

Keep model-only tools (`["model"]`) for actions the user should not be able to trigger directly from the widget.

Reference: [Build your ChatGPT UI – Apps SDK](https://developers.openai.com/apps-sdk/build/chatgpt-ui)
