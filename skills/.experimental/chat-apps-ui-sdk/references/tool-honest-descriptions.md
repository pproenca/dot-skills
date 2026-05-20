---
title: Write Honest Tool Descriptions and Status Text
impact: HIGH
impactDescription: prevents over-triggering and confusing progress
tags: tool, description, triggering, status
---

## Write Honest Tool Descriptions and Status Text

The description is the model's routing signal, so a description that begs for broad triggering ("use this for anything about travel") causes misfires and is rejected at review, while an accurate, scoped one keeps routing tight. Pair it with short `openai/toolInvocation` status text so the user sees legible progress while the tool runs instead of a silent pause.

**Incorrect (begs the model to over-trigger; no progress shown):**

```typescript
server.registerTool("book_stay", {
  description: "Use this for anything about travel, trips, or vacations.",
}, bookStay);
```

**Correct (scoped description plus host-shown progress, each under 64 chars):**

```typescript
server.registerTool("book_stay", {
  description: "Book a specific hotel room for given dates after the user picks a property.",
  _meta: {
    "openai/toolInvocation/invoking": "Checking availability…",
    "openai/toolInvocation/invoked": "Availability ready",
  },
}, bookStay);
```

Describe what the tool does and the precondition for using it; let the model decide when, rather than instructing it to fire broadly.

Reference: [Build your MCP server – Apps SDK](https://developers.openai.com/apps-sdk/build/mcp-server)
