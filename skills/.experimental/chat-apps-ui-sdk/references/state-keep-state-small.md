---
title: Keep Widget State Small and Serializable
impact: MEDIUM
impactDescription: reduces per-turn round-trip size
tags: state, serialization, size, performance
---

## Keep Widget State Small and Serializable

Widget state is serialized and transported with each turn, so storing whole result sets or non-serializable values (DOM nodes, class instances) there bloats every round-trip and can exceed the host's size limit, after which persistence silently fails. Persist identifiers and view flags; re-derive the heavy data from the tool result, which the widget already received.

**Incorrect (whole result set in widget state; serialized and shipped every turn):**

```tsx
window.openai.setWidgetState({ allListings: listings }); // hundreds of objects per round-trip
```

**Correct (persist identifiers and view flags; re-derive heavy data from tool output):**

```tsx
window.openai.setWidgetState({ selectedId: listing.id, sort: "price" });
```

Reference: [Reference – Apps SDK](https://developers.openai.com/apps-sdk/reference)
