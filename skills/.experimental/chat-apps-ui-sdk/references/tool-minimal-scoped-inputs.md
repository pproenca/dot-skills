---
title: Request Minimal, Task-Scoped Tool Inputs
impact: HIGH
impactDescription: prevents privacy rejections and over-broad triggers
tags: tool, inputs, privacy, schema
---

## Request Minimal, Task-Scoped Tool Inputs

An input schema should ask for exactly what the task needs and nothing more. Requesting the full conversation, raw transcripts, or broad contextual fields widens the model's trigger surface so the tool fires when it shouldn't, and it trips privacy review for over-collection. Narrow inputs make the model's decision to call the tool precise and keep the data you handle to a minimum.

**Incorrect (asks for the whole transcript and identity it doesn't need):**

```typescript
server.registerTool("summarize_thread", {
  inputSchema: { conversationHistory: z.array(z.string()), userEmail: z.string(), threadId: z.string() },
}, summarizeThread);
```

**Correct (ask only for the identifier the task operates on):**

```typescript
server.registerTool("summarize_thread", { inputSchema: { threadId: z.string() } }, summarizeThread);
```

If the task genuinely needs user context, resolve it server-side from an authenticated session rather than accepting it as a model-supplied argument (see [[sec-enforce-server-side-auth]]).

Reference: [App submission guidelines – Apps SDK](https://developers.openai.com/apps-sdk/app-submission-guidelines)
