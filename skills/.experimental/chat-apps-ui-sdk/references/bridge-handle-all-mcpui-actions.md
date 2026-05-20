---
title: Handle Every MCP-UI onUIAction Type
impact: MEDIUM-HIGH
impactDescription: prevents silently dead UI controls
tags: bridge, mcp-ui, onuiaction, actions
---

## Handle Every MCP-UI onUIAction Type

With MCP-UI's `UIResourceRenderer`, the iframe emits typed actions through a single `onUIAction` callback: `tool`, `prompt`, `link`, `intent`, and `notify`, each with its own payload shape. Handle only `tool` and the link buttons, prompt chips, and toasts in the same widget silently do nothing — which users read as a broken app. Route every action type the component can emit.

**Incorrect (only tool actions wired; link and prompt controls no-op):**

```tsx
<UIResourceRenderer resource={res}
  onUIAction={(a) => { if (a.type === "tool") client.callTool(a.payload.toolName, a.payload.params); }} />
```

**Correct (route each action type to its host behavior):**

```tsx
<UIResourceRenderer resource={res} onUIAction={(a) => {
  switch (a.type) {
    case "tool":   return client.callTool(a.payload.toolName, a.payload.params);
    case "prompt": return sendUserTurn(a.payload.prompt);
    case "link":   return openExternal(a.payload.url);
    case "intent": return routeIntent(a.payload.intent, a.payload.params);
    case "notify": return toast(a.payload.message);
  }
}} />
```

Reference: [MCP-UI client overview](https://mcpui.dev/guide/client/overview)
