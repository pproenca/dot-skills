---
title: Constrain to Nearest Neighbor Views
impact: HIGH
impactDescription: prevents brittle layouts that break when views are reordered
tags: layout, constraints, neighbors, maintainability
---

## Constrain to Nearest Neighbor Views

Constraints should reference the nearest sibling or the immediate container rather than distant views in the hierarchy. When a view is constrained to a non-adjacent sibling, reordering or removing an intermediate view breaks the layout chain silently, requiring a full constraint audit to diagnose.

**Incorrect (view C constrained to distant view A, skipping view B):**

```xml
<subviews>
    <label id="section-header" text="Payment Method"/>
    <imageView id="card-icon" image="credit-card"/>
    <label id="card-number" text="**** **** **** 4242"/>
</subviews>
<constraints>
    <constraint firstItem="section-header" firstAttribute="top"
               secondItem="safe-area" secondAttribute="top" constant="16"/>
    <constraint firstItem="card-icon" firstAttribute="top"
               secondItem="section-header" secondAttribute="bottom" constant="12"/>
    <!-- Skips card-icon, couples card-number to section-header -->
    <constraint firstItem="card-number" firstAttribute="top"
               secondItem="section-header" secondAttribute="bottom" constant="56"/>
</constraints>
```

**Correct (each view constrained to its immediate neighbor):**

```xml
<subviews>
    <label id="section-header" text="Payment Method"/>
    <imageView id="card-icon" image="credit-card"/>
    <label id="card-number" text="**** **** **** 4242"/>
</subviews>
<constraints>
    <constraint firstItem="section-header" firstAttribute="top"
               secondItem="safe-area" secondAttribute="top" constant="16"/>
    <constraint firstItem="card-icon" firstAttribute="top"
               secondItem="section-header" secondAttribute="bottom" constant="12"/>
    <constraint firstItem="card-number" firstAttribute="top"
               secondItem="card-icon" secondAttribute="bottom" constant="8"/>
</constraints>
```

**Benefits:**

- Inserting, removing, or reordering views only requires updating adjacent constraints
- Constraint constants reflect actual visual spacing, not cumulative offsets
- Easier to debug in Xcode's constraint inspector

Reference: [Auto Layout Guide - Anatomy of a Constraint](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/AnatomyofaConstraint.html)
