---
title: Assign Distinct Priorities to Optional Constraints
impact: MEDIUM
impactDescription: prevents unpredictable constraint breaking
tags: layout, priorities, optional-constraints, debugging
---

## Assign Distinct Priorities to Optional Constraints

When Auto Layout cannot satisfy all constraints, it breaks the constraint with the lowest priority. If two optional constraints share the same priority, the engine picks one arbitrarily, producing different results across devices or OS versions. Assigning distinct priorities makes constraint breaking deterministic and debuggable.

**Incorrect (two optional constraints with identical priority):**

```xml
<label id="subtitle-label" text="Premium Member Since 2019">
    <rect key="frame" x="16" y="60" width="343" height="21"/>
    <constraints>
        <!-- Both priority=750: Auto Layout picks one to break at random -->
        <constraint firstItem="subtitle-label" firstAttribute="trailing"
                   secondItem="safe-area" secondAttribute="trailing"
                   constant="16" priority="750"/>
        <constraint firstItem="subtitle-label" firstAttribute="width"
                   relation="greaterThanOrEqual" constant="280" priority="750"/>
    </constraints>
</label>
```

**Correct (distinct priorities so breaking order is predictable):**

```xml
<label id="subtitle-label" text="Premium Member Since 2019">
    <rect key="frame" x="16" y="60" width="343" height="21"/>
    <constraints>
        <!-- Priority 750: preferred trailing alignment -->
        <constraint firstItem="subtitle-label" firstAttribute="trailing"
                   secondItem="safe-area" secondAttribute="trailing"
                   constant="16" priority="750"/>
        <!-- Priority 749: breaks first, allowing trailing to win -->
        <constraint firstItem="subtitle-label" firstAttribute="width"
                   relation="greaterThanOrEqual" constant="280" priority="749"/>
    </constraints>
</label>
```

**Benefits:**

- Console logs clearly identify which constraint was broken and why
- Behavior is identical across all devices and OS versions
- Easier to tune layout trade-offs by adjusting a single priority value

Reference: [Auto Layout Guide - Constraint Priorities](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/AnatomyofaConstraint.html#//apple_ref/doc/uid/TP40010853-CH9-SW19)
