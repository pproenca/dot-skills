---
title: Lift State Only When Multiple Components Read It
impact: CRITICAL
impactDescription: eliminates unnecessary parent re-renders, clearer ownership
tags: state, lifting, shared-state, ownership
---

## Lift State Only When Multiple Components Read It

Premature lifting places state in a component that does not use it directly, making ownership unclear and forcing unnecessary re-renders on every state change. Lift state only when a second component needs to read the same value — not before.

**Incorrect (state lifted to App for a single consumer):**

```tsx
function App() {
  // Only ShippingForm reads shippingAddress, but App re-renders on every field change
  const [shippingAddress, setShippingAddress] = useState<Address | null>(null);

  return (
    <div>
      <Navbar />
      <Sidebar />
      <ShippingForm address={shippingAddress} onAddressChange={setShippingAddress} />
      <RecommendedProducts />
    </div>
  );
}
```

**Correct (colocated first, lifted only when shared):**

```tsx
// Step 1: state lives in the only consumer
function ShippingForm() {
  const [shippingAddress, setShippingAddress] = useState<Address | null>(null);
  return <AddressFields address={shippingAddress} onChange={setShippingAddress} />;
}

// Step 2: when OrderSummary also needs the address, lift to shared parent
function CheckoutPage() {
  const [shippingAddress, setShippingAddress] = useState<Address | null>(null);

  // Both children read shippingAddress — lifting is justified
  return (
    <div>
      <ShippingForm address={shippingAddress} onAddressChange={setShippingAddress} />
      <OrderSummary shippingAddress={shippingAddress} />
    </div>
  );
}

function App() {
  return (
    <div>
      <Navbar />
      <Sidebar />
      <CheckoutPage /> {/* App never re-renders for address changes */}
      <RecommendedProducts />
    </div>
  );
}
```

Reference: [React Docs - Sharing State Between Components](https://react.dev/learn/sharing-state-between-components)
