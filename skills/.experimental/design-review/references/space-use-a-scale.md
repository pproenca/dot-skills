---
title: Size spacing from a consistent scale
tags: space, spacing, layout
---

## Size spacing from a consistent scale

Choosing margins and padding by eye yields values like 13px, 7px, and 22px that never quite line up, and the inconsistency reads as careless. Draw spacing from a fixed scale built on a base unit of 4px (4, 8, 12, 16, 24, 32, 48…) so the rhythm is consistent and the decisions are faster to make.

**Incorrect (arbitrary one-off values):**

```css
.pricing-card { padding: 13px 19px; margin-bottom: 22px; gap: 7px; }
```

**Correct (values snapped to a 4px-based scale):**

```css
.pricing-card { padding: 16px 24px; margin-bottom: 24px; gap: 8px; }
```

Reference: [Refactoring UI — Spacing and sizing systems](https://www.refactoringui.com/)
