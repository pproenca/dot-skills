---
title: Derive State Instead of Syncing
impact: HIGH
impactDescription: eliminates redundant state and sync bugs
tags: rerender, derived-state, state-management, computation
---

## Derive State Instead of Syncing

When one value can be computed from another, derive it during render instead of storing it in separate state. Synced state causes extra renders and can get out of sync.

**Incorrect (synced state, double render):**

```typescript
// screens/ProductDetails.tsx
export function ProductDetails({ product }: Props) {
  const [quantity, setQuantity] = useState(1);
  const [totalPrice, setTotalPrice] = useState(product.price);

  useEffect(() => {
    setTotalPrice(product.price * quantity);  // Causes second render
  }, [product.price, quantity]);

  return (
    <View>
      <QuantityPicker value={quantity} onChange={setQuantity} />
      <Text>Total: ${totalPrice}</Text>
    </View>
  );
}
```

**Correct (derived value, single render):**

```typescript
// screens/ProductDetails.tsx
export function ProductDetails({ product }: Props) {
  const [quantity, setQuantity] = useState(1);
  const totalPrice = product.price * quantity;  // Computed during render

  return (
    <View>
      <QuantityPicker value={quantity} onChange={setQuantity} />
      <Text>Total: ${totalPrice}</Text>
    </View>
  );
}
```

**When to derive:**
- Filtered/sorted lists from source data
- Computed totals, averages, counts
- Boolean flags based on other state
- Formatted display values

**When to use useMemo:** Wrap in `useMemo` if the derivation is expensive and deps rarely change.

Reference: [Choosing the State Structure](https://react.dev/learn/choosing-the-state-structure#avoid-redundant-state)
