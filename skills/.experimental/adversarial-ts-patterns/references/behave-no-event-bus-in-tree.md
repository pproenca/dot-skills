---
title: No event bus between components that share a React ancestor
tags: behave, observer, mediator, event-bus, react
---

## No event bus between components that share a React ancestor

The wrong default is reaching for an Observer/Mediator port — a Node `EventEmitter`, `mitt`, or a hand-rolled `subscribe`/`publish` module — to make two React components talk. Inside one React tree, that traffic already has a designed channel — lift the shared state to the closest common ancestor and pass it down, or use context for deep trees. The bus version creates state updates React cannot see the provenance of — no dependency into the render graph, subscriptions that leak when cleanup is forgotten, ordering that depends on subscriber registration, and a data flow invisible to the React DevTools.

**Evidence of violation:** an emitter or pub/sub module imported by two or more components that are mounted in the same React tree (they share a common ancestor component), used to move application state between them. The carve-out is a genuine boundary crossing — communication between separate React roots, or between React and a non-React system (a map library, a legacy jQuery widget, a WebSocket); buses exist for boundaries, not for siblings.

**Incorrect (siblings coupled through a global bus):**

```tsx
// cartBus.ts
export const cartBus = new EventTarget()

// AddToCartButton.tsx
cartBus.dispatchEvent(new CustomEvent("item-added", { detail: item }))

// CartBadge.tsx
useEffect(() => {
  const onAdd = (e: Event) => setCount(c => c + 1)
  cartBus.addEventListener("item-added", onAdd)
  return () => cartBus.removeEventListener("item-added", onAdd)
}, [])
```

**Correct (state lifted to the common ancestor):**

```tsx
function ShopPage() {
  const [cartItems, setCartItems] = useState<Item[]>([])
  return (
    <>
      <CartBadge count={cartItems.length} />
      <AddToCartButton onAdd={(item) => setCartItems([...cartItems, item])} />
    </>
  )
}
```

Reference: [react.dev — Sharing State Between Components (lifting state up)](https://react.dev/learn/sharing-state-between-components)
