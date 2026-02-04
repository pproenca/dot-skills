---
title: Defer await Until Value Needed
impact: MEDIUM
impactDescription: 20-50% faster by overlapping async work
tags: async, defer, promises, optimization
---

## Defer await Until Value Needed

Start promises immediately but defer `await` until you actually need the value. This allows intermediate synchronous code to run while the promise is pending.

**Incorrect (await blocks immediately):**

```typescript
// screens/CheckoutScreen.tsx
export async function processCheckout(cartId: string, userId: string) {
  const cart = await fetchCart(cartId);  // Blocks here

  // Sync validation could run while cart fetches
  const shippingValid = validateShippingAddress(userId);
  if (!shippingValid) throw new Error('Invalid shipping');

  const inventory = await checkInventory(cart.items);  // Blocks here
  return { cart, inventory };
}
```

**Correct (start early, await late):**

```typescript
// screens/CheckoutScreen.tsx
export async function processCheckout(cartId: string, userId: string) {
  // Start both fetches immediately
  const cartPromise = fetchCart(cartId);
  const inventoryCheck = async () => {
    const cart = await cartPromise;
    return checkInventory(cart.items);
  };

  // Sync validation runs while cart fetches
  const shippingValid = validateShippingAddress(userId);
  if (!shippingValid) throw new Error('Invalid shipping');

  // Now await only when we need the values
  const [cart, inventory] = await Promise.all([
    cartPromise,
    inventoryCheck(),
  ]);

  return { cart, inventory };
}
```

**Key insight:** The promise starts executing when called, not when awaited. Use this to overlap network and computation.

Reference: [Async/Await Best Practices](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Promises)
