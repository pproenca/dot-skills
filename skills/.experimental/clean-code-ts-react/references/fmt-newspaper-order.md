---
title: Order Files Top-Down Like a Newspaper
impact: HIGH
impactDescription: lets readers grasp a file's purpose without scrolling to find the headline
tags: fmt, file-structure, top-down, readability
---

## Order Files Top-Down Like a Newspaper

A newspaper article puts the headline first, then the lede, then supporting details. A code file should do the same: the exported, high-level entity at the top; the helpers that support it below. A reader opening the file should see what it's FOR before they see how it works.

**Incorrect (helpers first; reader scrolls to find the headline):**

```tsx
// File: Checkout.tsx — but you can't tell that by reading top-down.
import { z } from 'zod';
import type { Cart, Coupon } from '@/types';

function formatPrice(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

function validateCoupon(code: string, cart: Cart): Coupon | null {
  // ... 30 lines ...
}

function calculateShipping(cart: Cart): number {
  // ... 20 lines ...
}

// Reader scrolls 80 lines down before discovering what this file exports.
export default function Checkout({ cart }: { cart: Cart }) {
  // ... uses the helpers above ...
}
```

**Correct (export at the top; helpers below):**

```tsx
// File: Checkout.tsx — purpose visible immediately.
import { z } from 'zod';
import type { Cart, Coupon } from '@/types';

export default function Checkout({ cart }: { cart: Cart }) {
  // Reader sees what this file is FOR first; helpers are an implementation
  // detail one scroll away.
  const shipping = calculateShipping(cart);
  // ... uses the helpers below ...
}

function calculateShipping(cart: Cart): number {
  // ... 20 lines ...
}

function validateCoupon(code: string, cart: Cart): Coupon | null {
  // ... 30 lines ...
}

function formatPrice(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}
```

**When NOT to apply this pattern:**
- Tooling that expects a specific position for exports (some bundlers and test runners care about the position of `export default` or named exports — follow the tool).
- Established team convention of "imports → constants → types → helpers → exports" — consistency across the codebase trumps any single rule.
- Types and interfaces consumed by the export — often clearest defined right above the export so the reader sees the contract before the implementation.

**Why this matters:** A file's first 20 lines are its abstract. Spend them on the entity the file exists for, not on plumbing.

Reference: [Clean Code, Chapter 5: Formatting — The Newspaper Metaphor](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
