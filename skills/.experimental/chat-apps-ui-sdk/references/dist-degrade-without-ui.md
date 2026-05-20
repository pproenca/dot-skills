---
title: Return a Text Fallback When UI Is Unsupported
impact: MEDIUM
impactDescription: maintains output on hosts without widgets
tags: dist, fallback, degradation, content
---

## Return a Text Fallback When UI Is Unsupported

Some hosts and model-only contexts will not render your widget at all. If the answer lives only in `_meta` for the component, those users get nothing useful. Always include meaningful `structuredContent` plus a natural-language `content` summary so the response stands on its own, and treat the widget as an enhancement layered on top of a complete text answer.

**Incorrect (data only in _meta for the widget; a UI-less host shows nothing):**

```typescript
return { _meta: { items: order.items } };
```

**Correct (complete text answer first; the widget enhances it):**

```typescript
return {
  structuredContent: { orderId: order.id, status: order.status, eta: order.eta },
  content: [{ type: "text", text: `Order ${order.id} is ${order.status}, arriving ${order.eta}.` }],
  _meta: { items: order.items }, // rich detail for the widget when it renders
};
```

Reference: [MCP Apps – Bringing UI to MCP clients](https://blog.modelcontextprotocol.io/posts/2026-01-26-mcp-apps/)
