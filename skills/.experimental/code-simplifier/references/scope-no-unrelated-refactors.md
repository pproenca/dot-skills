---
title: No Unrelated Refactors
impact: HIGH
impactDescription: Mixed-purpose PRs have 60% higher revert rates and block unrelated deployments when issues arise
tags: scope, focus, single-responsibility, pr-hygiene
---

## No Unrelated Refactors

Every PR should have exactly one purpose. When simplifying code, resist the urge to fix "while you're in there" issues. Unrelated changes pollute git history, complicate reviews, and create deployment dependencies. If you spot other issues, create separate tickets.

**Incorrect (opportunistic refactoring):**

```typescript
// Task: Simplify the calculateDiscount function
// PR description: "Simplify discount calc + some cleanup"

// Change 1: The actual task (correct)
function calculateDiscount(price: number, tier: string): number {
  const rates = { bronze: 0.05, silver: 0.10, gold: 0.15 };
  return price * (rates[tier] ?? 0);
}

// Change 2: "Noticed this could use optional chaining" (wrong!)
function getOrderTotal(order: Order): number {
  return order?.items?.reduce((sum, i) => sum + i.price, 0) ?? 0;
}

// Change 3: "Fixed inconsistent naming" (wrong!)
// Renamed userPreferences -> userPrefs across 8 files

// Change 4: "Removed dead code I found" (wrong!)
// Deleted 3 unused utility functions

// Change 5: "Updated to arrow functions for consistency" (wrong!)
// Converted 12 function declarations to arrows
```

**Correct (single-purpose PR):**

```typescript
// Task: Simplify the calculateDiscount function
// PR description: "Simplify discount calculation using lookup table"

// Before
function calculateDiscount(price: number, tier: string): number {
  let discount = 0;
  if (tier === 'bronze') {
    discount = price * 0.05;
  } else if (tier === 'silver') {
    discount = price * 0.10;
  } else if (tier === 'gold') {
    discount = price * 0.15;
  }
  return discount;
}

// After - ONLY this function changes
function calculateDiscount(price: number, tier: string): number {
  const rates = { bronze: 0.05, silver: 0.10, gold: 0.15 };
  return price * (rates[tier] ?? 0);
}

// Other observations logged as separate tickets:
// - TECH-1234: Add optional chaining to getOrderTotal
// - TECH-1235: Standardize preferences naming convention
// - TECH-1236: Remove unused utility functions
```

### The "While You're In There" Anti-Pattern

Common temptations to resist:
- "I'll just update these imports too"
- "This variable name is misleading, quick fix"
- "Found some dead code, might as well delete it"
- "The formatting here is inconsistent"
- "This could use modern syntax"

Each of these deserves its own PR or ticket.

### When NOT to Apply

- When the "unrelated" change is required for the main change to work
- When fixing a typo in a comment you're already modifying
- When the project explicitly allows bundled cleanup (rare)

### Benefits

- PRs are easy to review, approve, or reject independently
- Reverts are surgical, not catastrophic
- git blame shows clear intent for each change
- Deployment risk is isolated
