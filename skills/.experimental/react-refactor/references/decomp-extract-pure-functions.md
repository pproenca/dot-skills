---
title: Extract Pure Functions from Component Bodies
impact: HIGH
impactDescription: pure functions testable without React, 10× faster unit tests
tags: decomp, pure-functions, testability, performance
---

## Extract Pure Functions from Component Bodies

Utility logic defined inside a component body is untestable without rendering the component and re-executes its definition on every render. Extracting pure functions to module scope makes them independently testable with plain assertions and eliminates unnecessary function re-creation.

**Incorrect (formatting and calculation logic defined inside the component):**

```tsx
function ShippingEstimate({ cart, destination }: ShippingEstimateProps) {
  // Re-created on every render, untestable without rendering ShippingEstimate
  function calculateWeight(items: CartItem[]): number {
    return items.reduce((total, cartItem) => {
      const unitWeight = cartItem.weight ?? DEFAULT_WEIGHT;
      return total + unitWeight * cartItem.quantity;
    }, 0);
  }

  function formatDeliveryWindow(minDays: number, maxDays: number): string {
    const start = addBusinessDays(new Date(), minDays);
    const end = addBusinessDays(new Date(), maxDays);
    return `${formatDate(start)} – ${formatDate(end)}`;
  }

  function getShippingTier(weightKg: number): ShippingTier {
    if (weightKg < 1) return { tier: "light", baseCost: 4.99, perKg: 0 };
    if (weightKg < 10) return { tier: "standard", baseCost: 7.99, perKg: 1.5 };
    return { tier: "heavy", baseCost: 14.99, perKg: 2.5 };
  }

  const totalWeight = calculateWeight(cart.items);
  const tier = getShippingTier(totalWeight);
  const cost = tier.baseCost + totalWeight * tier.perKg;
  const deliveryWindow = formatDeliveryWindow(tier.minDays, tier.maxDays);

  return (
    <div>
      <span>{tier.tier} shipping: {formatCurrency(cost)}</span>
      <span>Estimated delivery: {deliveryWindow}</span>
    </div>
  );
}
```

**Correct (pure functions at module scope, tested independently):**

```tsx
// Testable with plain assertions: calculateWeight([{ weight: 2, quantity: 3 }]) === 6
export function calculateWeight(items: CartItem[]): number {
  return items.reduce((total, cartItem) => {
    const unitWeight = cartItem.weight ?? DEFAULT_WEIGHT;
    return total + unitWeight * cartItem.quantity;
  }, 0);
}

export function getShippingTier(weightKg: number): ShippingTier {
  if (weightKg < 1) return { tier: "light", baseCost: 4.99, perKg: 0 };
  if (weightKg < 10) return { tier: "standard", baseCost: 7.99, perKg: 1.5 };
  return { tier: "heavy", baseCost: 14.99, perKg: 2.5 };
}

export function formatDeliveryWindow(minDays: number, maxDays: number): string {
  const start = addBusinessDays(new Date(), minDays);
  const end = addBusinessDays(new Date(), maxDays);
  return `${formatDate(start)} – ${formatDate(end)}`;
}

function ShippingEstimate({ cart, destination }: ShippingEstimateProps) {
  const totalWeight = calculateWeight(cart.items);
  const tier = getShippingTier(totalWeight);
  const cost = tier.baseCost + totalWeight * tier.perKg;
  const deliveryWindow = formatDeliveryWindow(tier.minDays, tier.maxDays);

  return (
    <div>
      <span>{tier.tier} shipping: {formatCurrency(cost)}</span>
      <span>Estimated delivery: {deliveryWindow}</span>
    </div>
  );
}
```

Reference: [Keeping Components Pure](https://react.dev/learn/keeping-components-pure)
