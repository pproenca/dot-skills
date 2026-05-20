---
title: Separate Widget, Server, and Model State
impact: HIGH
impactDescription: prevents state drift across re-renders
tags: state, ownership, widget-state, model-context
---

## Separate Widget, Server, and Model State

Chat apps have three stores with three owners, and conflating them is the root of most state bugs. Ephemeral UI state (the active tab, a selection) belongs in `setWidgetState`; the source of truth (the booking, the order) belongs in your backend, reached through a tool call; model-visible facts (what the user just chose) go through the model-context update. Keep one fact in one place so the widget, server, and model never disagree.

**Incorrect (everything in local React state; lost on re-mount, invisible to server and model):**

```tsx
const [seat, setSeat] = useState<string | null>(null);
const choose = (s: string) => setSeat(s); // nothing persisted, reserved, or told to the model
```

**Correct (route each fact to its owner):**

```tsx
const app = new App(); // MCP Apps bridge instance
const choose = (s: string) => {
  window.openai.setWidgetState({ ...window.openai.widgetState, seat: s }); // ephemeral UI
  window.openai.callTool("reserve_seat", { flightId, seat: s });           // server source of truth
  app.updateModelContext({ content: [{ type: "text", text: `Selected seat ${s}.` }] }); // model in the loop
};
```

`app` is the MCP Apps bridge (`new App()` from `@modelcontextprotocol/ext-apps`); on the Apps SDK alone, the same three responsibilities map to `setWidgetState`, `callTool`, and the model-context update.

Reference: [Design components – Apps SDK](https://developers.openai.com/apps-sdk/plan/components)
