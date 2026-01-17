---
title: Use Props as Feature Boundaries
impact: MEDIUM-HIGH
impactDescription: Creates clear interfaces between features; enables feature composition
tags: comp, props, interface, boundary
---

## Use Props as Feature Boundaries

When features interact, use props to define the interface. The receiving component should not know about the providing feature's internals. This creates a clear boundary that allows either side to change independently.

**Incorrect (feature internals exposed):**

```typescript
// Checkout component knows about Cart's internal structure
import { useCartStore } from '@/features/cart/stores/cartStore';

function CheckoutSummary() {
  // Directly accessing cart's internal state structure
  const items = useCartStore(s => s.items);
  const appliedCoupons = useCartStore(s => s.coupons);
  const shippingMethod = useCartStore(s => s.shipping.method);

  // If cart store changes structure, this breaks
  return <div>...</div>;
}
```

**Correct (props as boundary):**

```typescript
// Define explicit interface for what checkout needs
interface CheckoutSummaryProps {
  items: Array<{
    id: string;
    name: string;
    price: number;
    quantity: number;
  }>;
  subtotal: number;
  discount: number;
  shipping: number;
  total: number;
}

function CheckoutSummary({ items, subtotal, discount, shipping, total }: CheckoutSummaryProps) {
  // Component only knows about its props, not cart internals
  return (
    <div>
      {items.map(item => (
        <LineItem key={item.id} item={item} />
      ))}
      <Subtotal amount={subtotal} />
      {discount > 0 && <Discount amount={discount} />}
      <Shipping amount={shipping} />
      <Total amount={total} />
    </div>
  );
}

// App layer transforms cart state to checkout props
function CheckoutPage() {
  const cart = useCartStore();

  // Transformation happens at composition point
  const summaryProps = {
    items: cart.items.map(i => ({
      id: i.id,
      name: i.product.name,
      price: i.product.price,
      quantity: i.quantity,
    })),
    subtotal: cart.getSubtotal(),
    discount: cart.getDiscount(),
    shipping: cart.getShippingCost(),
    total: cart.getTotal(),
  };

  return <CheckoutSummary {...summaryProps} />;
}
```

**Benefits:**
- CheckoutSummary doesn't import from cart feature
- Cart can restructure without breaking checkout
- CheckoutSummary is easily testable with mock props

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)
