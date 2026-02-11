---
title: Write Characterization Tests Before Refactoring
impact: MEDIUM
impactDescription: catches 90% of unintended behavior changes during refactoring
tags: safety, characterization-tests, refactoring, regression
---

## Write Characterization Tests Before Refactoring

Refactoring without tests means changing behavior without a safety net. Bugs introduced during refactoring are invisible until production. Characterization tests lock in the current behavior first, so any unintended change triggers a failure immediately, making the refactoring reversible.

**Incorrect (refactor first — no way to detect regressions):**

```tsx
// Step 1: Immediately refactor the monolith with no tests
// ShippingCalculator had complex conditional logic
// Developer "simplifies" it, unknowingly changing edge case behavior

export function calculateShippingCost(
  weight: number,
  destination: string,
  isExpedited: boolean,
): number {
  // Refactored version — looks cleaner but subtly broke the weight >= 50 case
  const baseRate = destination === "international" ? 25 : 10;
  const weightSurcharge = weight * 0.5;
  const expeditedMultiplier = isExpedited ? 1.5 : 1;
  return (baseRate + weightSurcharge) * expeditedMultiplier;
  // Original had: weight >= 50 ? flatRate : perPoundRate
  // Bug ships to production undetected
}
```

**Correct (characterization tests first — behavior locked before touching code):**

```tsx
// Step 1: Write tests that capture CURRENT behavior before any changes
import { calculateShippingCost } from "./ShippingCalculator";

describe("calculateShippingCost — characterization", () => {
  test("domestic standard under 50lbs", () => {
    expect(calculateShippingCost(10, "domestic", false)).toBe(15);
  });

  test("domestic standard at 50lbs threshold", () => {
    // Discovered: 50lb+ uses flat rate $45, not per-pound
    expect(calculateShippingCost(50, "domestic", false)).toBe(45);
  });

  test("domestic expedited under 50lbs", () => {
    expect(calculateShippingCost(10, "domestic", true)).toBe(22.5);
  });

  test("international standard", () => {
    expect(calculateShippingCost(10, "international", false)).toBe(30);
  });

  test("international expedited at threshold", () => {
    expect(calculateShippingCost(50, "international", true)).toBe(90);
  });
});

// Step 2: Now refactor — tests catch the 50lb edge case immediately
// Step 3: All 5 tests pass = safe to ship
```

Reference: [Michael Feathers - Working Effectively with Legacy Code](https://www.oreilly.com/library/view/working-effectively-with/0131177052/)
