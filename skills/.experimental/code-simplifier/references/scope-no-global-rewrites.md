---
title: Avoid Global Rewrites and Architectural Changes
impact: HIGH
impactDescription: Global renames touch 50+ files, require full regression testing, and block other PRs for days with merge conflicts
tags: scope, global-changes, architecture, risk-management
---

## Avoid Global Rewrites and Architectural Changes

Code simplification is not the time for sweeping changes. Global renames, mass migrations, or architectural shifts disguised as "simplification" create merge conflict nightmares and require extensive testing. These changes need dedicated planning, not drive-by implementation.

**Incorrect (global rename during simplification):**

```typescript
// Task: Simplify the checkout module
// "To simplify, I'll rename 'cart' to 'basket' everywhere for clarity"

// 127 files changed:
// - src/components/Cart.tsx -> Basket.tsx
// - src/hooks/useCart.ts -> useBasket.ts
// - src/stores/cartStore.ts -> basketStore.ts
// - src/api/cart/*.ts -> basket/*.ts
// - src/types/cart.ts -> basket.ts
// - tests/**/*cart* -> *basket*
// - docs/cart.md -> basket.md
// Plus all import statements, variable names, comments...

// "Also modernized the state management while I was at it"
// Migrated from Redux to Zustand across 45 files
```

**Correct (contained simplification):**

```typescript
// Task: Simplify the checkout module
// PR only touches checkout logic, preserves existing naming

// Before - checkout/processOrder.ts
export async function processOrder(cart: Cart, payment: Payment) {
  const validation = validateCart(cart);
  if (validation.isValid === false) {
    throw new ValidationError(validation.errors);
  }
  const total = calculateTotal(cart);
  const tax = calculateTax(total, cart.shippingAddress);
  const finalAmount = total + tax;
  const charge = await chargePayment(payment, finalAmount);
  if (charge.success === true) {
    return createOrder(cart, charge);
  }
  throw new PaymentError(charge.error);
}

// After - same file, same naming conventions
export async function processOrder(cart: Cart, payment: Payment) {
  validateCart(cart); // throws on invalid

  const total = calculateTotal(cart);
  const finalAmount = total + calculateTax(total, cart.shippingAddress);

  const charge = await chargePayment(payment, finalAmount);
  if (!charge.success) throw new PaymentError(charge.error);

  return createOrder(cart, charge);
}

// Note: "cart vs basket" naming discussion logged as TECH-1234
// Note: State management modernization planned for Q3 roadmap
```

### Changes That Require Separate Planning

| Change Type | Why It's Not Simplification |
|-------------|---------------------------|
| Global renames | Touches every file, massive merge conflicts |
| Dependency upgrades | Requires compatibility testing |
| Architecture changes | Needs design review and migration plan |
| Pattern migrations | (callbacks->promises, classes->hooks) Need incremental rollout |
| Directory restructuring | Breaks imports across entire codebase |

### When NOT to Apply

- During a planned, scheduled migration sprint
- When the global change is the explicit, approved task
- When a breaking change is already coordinated with the team

### Benefits

- Other developers can continue merging their work
- No surprise regressions in unrelated features
- Changes can be reviewed by domain experts
- Rollback is possible without reverting weeks of work
