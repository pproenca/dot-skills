---
title: Push User Decisions to Model Context
impact: MEDIUM-HIGH
impactDescription: prevents incoherent follow-up turns
tags: state, update-model-context, model, coherence
---

## Push User Decisions to Model Context

When the user acts inside the widget — picks a date, selects a row, toggles an option — the model cannot see it unless you call the model-context update (`ui/update-model-context`, exposed as `app.updateModelContext`). Skip it and the next turn the model contradicts the visible UI, asking "which date did you want?" because it never learned the choice the user already made on screen.

**Incorrect (user picks a date in the widget; the model is never told):**

```tsx
const pick = (iso: string) => setDate(iso);
```

**Correct (tell the model what changed so the next turn stays coherent):**

```tsx
import { App } from "@modelcontextprotocol/ext-apps";
const app = new App();
const pick = (iso: string) => {
  setDate(iso);
  app.updateModelContext({ content: [{ type: "text", text: `User chose the ${iso} departure.` }] });
};
```

Update model context for decisions the model should reason about — not for every hover or scroll, which would just add noise.

Reference: [MCP Apps – Bringing UI to MCP clients](https://blog.modelcontextprotocol.io/posts/2026-01-26-mcp-apps/)
