---
title: Split Tool Output Across structuredContent, content, and _meta
impact: CRITICAL
impactDescription: prevents leaking private data to the model
tags: tool, structured-content, mcp, data-contract
---

## Split Tool Output Across structuredContent, content, and _meta

A tool result has three channels with three different audiences, and collapsing them is the single most consequential mistake in chat-app design. `structuredContent` is read by **both** the model and the widget — keep it small and meaningful. `content` is natural-language narration the model speaks back. `_meta` is delivered **only** to the widget and never reaches the model. Dumping everything into `content` floods the model with raw rows and starves the widget of typed data; putting private detail in `structuredContent` sends it straight to the model.

**Incorrect (whole dataset in model-visible text):**

```typescript
// 40 rows serialized into content -> the model reads all of it, the widget gets nothing typed:
return { content: [{ type: "text", text: JSON.stringify(flights) }] };
```

**Correct (three audiences, three channels):**

```typescript
return {
  structuredContent: { origin, destination, cheapestUsd: flights[0].priceUsd }, // model + widget read this
  content: [{ type: "text", text: `Found ${flights.length} flights to ${destination}.` }], // model narrates
  _meta: { flights }, // full rows for the widget only — never sent to the model
};
```

Keep `structuredContent` concise: it counts against the model's context on every turn. Heavy rows belong in `_meta`, which the widget reads via the bridge (see [[bridge-render-from-notifications]]).

Reference: [Build your MCP server – Apps SDK](https://developers.openai.com/apps-sdk/build/mcp-server)
