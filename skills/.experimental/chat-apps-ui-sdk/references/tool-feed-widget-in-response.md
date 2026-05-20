---
title: Return Everything the Widget Needs in One Response
impact: HIGH
impactDescription: eliminates client-side fetch waterfalls
tags: tool, payload, waterfalls, performance
---

## Return Everything the Widget Needs in One Response

The widget boots inside a sandbox with no shared session, so if it has to call your API again after mount to fill in data, the user watches a second spinner and you end up re-implementing authentication inside the iframe. Put the full first-paint dataset in the tool result — concise fields in `structuredContent`, heavy rows in `_meta` — so the component renders immediately from data it already has.

**Incorrect (returns ids only; the component re-fetches details on mount):**

```typescript
// Widget mounts, then makes a second authenticated round-trip behind a spinner:
return { structuredContent: { orderId: order.id, status: order.status } };
```

**Correct (hydrate the widget in the same response; big rows kept off the model):**

```typescript
return {
  structuredContent: { orderId: order.id, status: order.status, totalUsd: order.totalUsd },
  _meta: { items: order.items, timeline: order.timeline }, // first paint needs no extra round-trip
};
```

**When NOT to apply:**
- Genuinely live data (a streaming price, a moving vehicle) should refresh via a tool call after first paint rather than ship a stale snapshot.

Reference: [Design components – Apps SDK](https://developers.openai.com/apps-sdk/plan/components)
