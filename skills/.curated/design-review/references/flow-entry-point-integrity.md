---
title: Make every page work as a first entry point
tags: flow, routing, navigation
---

## Make every page work as a first entry point

A screen that reads data handed to it by the previous screen breaks the moment someone deep-links, refreshes, or opens a shared URL — the in-memory state isn't there, so the page renders empty or throws. Derive everything a page needs from the URL and load it on mount, so the route is self-sufficient no matter how the user arrived.

**Incorrect (depends on state passed during navigation):**

```tsx
function OrderPage() {
  const { state } = useLocation();        // undefined on refresh or a shared link
  return <OrderDetail order={state.order} />;
}
```

**Correct (reads the id from the URL and loads its own data):**

```tsx
function OrderPage() {
  const { orderId } = useParams();
  const { data: order } = useOrder(orderId);   // works on refresh, deep link, share
  return order ? <OrderDetail order={order} /> : <OrderDetailSkeleton />;
}
```

Reference: [MDN — History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API)
