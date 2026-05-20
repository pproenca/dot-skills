---
title: Set readOnlyHint and destructiveHint Accurately
impact: CRITICAL
impactDescription: prevents unsafe auto-invocation and review rejection
tags: tool, annotations, safety, hints
---

## Set readOnlyHint and destructiveHint Accurately

Hosts read `readOnlyHint`, `destructiveHint`, and `openWorldHint` to decide whether to run a tool automatically or pause for explicit user confirmation. Labeling a state-changing tool as read-only invites the host to fire it silently — cancelling an order the user never confirmed. Missing or incorrect action labels are one of the most common causes of directory-review rejection, so annotate every tool to match what it actually does.

**Incorrect (a state-changing tool with no hints; the host may auto-run it):**

```typescript
server.registerTool("cancel_order", { inputSchema: { orderId: z.string() } }, cancelOrder);
```

**Correct (annotations mark it as a destructive write needing confirmation):**

```typescript
server.registerTool("cancel_order", {
  inputSchema: { orderId: z.string() },
  annotations: { readOnlyHint: false, destructiveHint: true, openWorldHint: true },
}, cancelOrder);
```

Read-only lookups should set `readOnlyHint: true`; anything that mutates external state needs `destructiveHint`, and anything that reaches the open internet needs `openWorldHint`.

Reference: [App submission guidelines – Apps SDK](https://developers.openai.com/apps-sdk/app-submission-guidelines)
