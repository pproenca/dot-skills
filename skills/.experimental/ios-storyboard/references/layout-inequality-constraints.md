---
title: Use Inequality Constraints for Flexible Minimums and Maximums
impact: MEDIUM
impactDescription: prevents truncation on smaller screens
tags: layout, inequality, flexible, minimum, maximum
---

## Use Inequality Constraints for Flexible Minimums and Maximums

Fixed-value constraints force a single size that may not fit all screen widths. Inequality constraints (`greaterThanOrEqual`, `lessThanOrEqual`) define flexible bounds, allowing views to grow or shrink within acceptable limits while preventing content from being truncated or stretching beyond a readable width.

**Incorrect (fixed width that truncates on iPhone SE):**

```xml
<button id="checkout-button" title="Proceed to Checkout">
    <rect key="frame" x="60" y="500" width="300" height="50"/>
    <constraints>
        <!-- Fixed 300pt overflows on 320pt-wide iPhone SE -->
        <constraint firstAttribute="width" constant="300"/>
    </constraints>
</button>
```

**Correct (inequality constraints with flexible range):**

```xml
<button id="checkout-button" title="Proceed to Checkout">
    <rect key="frame" x="60" y="500" width="300" height="50"/>
    <constraints>
        <constraint firstAttribute="width" relation="greaterThanOrEqual" constant="200"/>
        <constraint firstAttribute="width" relation="lessThanOrEqual" constant="400"/>
        <constraint firstAttribute="height" relation="greaterThanOrEqual" constant="44"/>
    </constraints>
</button>
```

**When NOT to use inequality constraints:**

- When a view must be an exact size (e.g., a square avatar thumbnail)
- When leading/trailing constraints already provide the flexibility needed

Reference: [Auto Layout Guide - Anatomy of a Constraint](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/AnatomyofaConstraint.html)
