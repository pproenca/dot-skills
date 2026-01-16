---
title: Use Context Sparingly for Feature State
impact: MEDIUM
impactDescription: Prevents context re-render cascades; keeps features portable
tags: state, context, provider, scope
---

## Use Context Sparingly for Feature State

Context is useful for dependency injection and app-wide configuration, but causes re-render cascades when used for frequently-changing state. Prefer feature stores or local state for dynamic data.

**Incorrect (frequently changing data in context):**

```typescript
// Every context consumer re-renders on any cart change
const CartContext = createContext<CartContextValue | null>(null);

function CartProvider({ children }) {
  const [items, setItems] = useState([]);
  const [total, setTotal] = useState(0);

  const addItem = (item) => {
    setItems([...items, item]);  // Re-renders all consumers
    setTotal(total + item.price);
  };

  return (
    <CartContext.Provider value={{ items, total, addItem }}>
      {children}  {/* Every consumer re-renders */}
    </CartContext.Provider>
  );
}

// Components re-render even if they only use `total`
function CartIcon() {
  const { total } = useContext(CartContext);  // Re-renders when items change
  return <span>{total}</span>;
}
```

**Correct (store with selectors):**

```typescript
// src/features/cart/stores/cartStore.ts
export const useCartStore = create((set, get) => ({
  items: [],
  addItem: (item) => set(s => ({ items: [...s.items, item] })),
  getTotal: () => get().items.reduce((sum, i) => sum + i.price, 0),
}));

// Only re-renders when selected state changes
function CartIcon() {
  const total = useCartStore(s => s.items.reduce((sum, i) => sum + i.price, 0));
  return <span>{total}</span>;
}

function CartItemCount() {
  const count = useCartStore(s => s.items.length);  // Only re-renders when count changes
  return <span>{count}</span>;
}
```

**When context is appropriate:**
- Dependency injection (API client, auth)
- Theme/locale (changes rarely)
- Feature flags (read-only)

**When to use stores:**
- Frequently updating state
- Multiple components need different slices
- Need fine-grained subscriptions

Reference: [Zustand Documentation](https://zustand-demo.pmnd.rs/)
