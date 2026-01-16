---
title: Use Searchable Names
impact: HIGH
impactDescription: enables quick codebase navigation and reduces debugging time
tags: name, searchable, constants, magic-numbers
---

## Use Searchable Names

Single-letter names and numeric constants are impossible to search for. Use named constants and descriptive variable names that can be grepped across the codebase.

**Incorrect (unnamed constants and short names):**

```typescript
function calculatePrice(qty: number, p: number): number {
  if (qty > 10) {
    return p * qty * 0.9  // What is 0.9?
  }
  if (qty > 5) {
    return p * qty * 0.95  // What is 0.95?
  }
  return p * qty + 4.99  // What is 4.99?
}

// Trying to search for "the 10% discount" is impossible
// Searching for "0.9" finds every unrelated decimal
```

**Correct (named constants and descriptive names):**

```typescript
const BULK_ORDER_THRESHOLD = 10
const MEDIUM_ORDER_THRESHOLD = 5
const BULK_DISCOUNT_RATE = 0.10
const MEDIUM_DISCOUNT_RATE = 0.05
const STANDARD_SHIPPING_FEE = 4.99

function calculatePrice(quantity: number, unitPrice: number): number {
  if (quantity > BULK_ORDER_THRESHOLD) {
    return unitPrice * quantity * (1 - BULK_DISCOUNT_RATE)
  }
  if (quantity > MEDIUM_ORDER_THRESHOLD) {
    return unitPrice * quantity * (1 - MEDIUM_DISCOUNT_RATE)
  }
  return unitPrice * quantity + STANDARD_SHIPPING_FEE
}

// Searching for "BULK_DISCOUNT" finds all related code instantly
```

**Name everything that has meaning:**
- Thresholds and limits
- Configuration values
- Status codes and error codes
- Array indices with special meaning
- Regex patterns

Reference: [Clean Code - Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
