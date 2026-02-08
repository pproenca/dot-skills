---
title: Use Leading and Trailing Instead of Left and Right
impact: CRITICAL
impactDescription: prevents broken layouts in RTL languages
tags: layout, leading, trailing, rtl, localization
---

## Use Leading and Trailing Instead of Left and Right

Leading and trailing attributes automatically flip in right-to-left (RTL) languages such as Arabic, Hebrew, and Urdu. Using left and right hardcodes the layout direction, breaking the UI for over 30 RTL languages representing hundreds of millions of users.

**Incorrect (hardcoded left and right attributes):**

```xml
<constraints>
    <!-- Left/Right ignores RTL languages entirely -->
    <constraint firstItem="profile-image" firstAttribute="left"
               secondItem="cell-content" secondAttribute="left" constant="16"/>
    <constraint firstItem="username-label" firstAttribute="left"
               secondItem="profile-image" secondAttribute="right" constant="12"/>
    <constraint firstItem="cell-content" firstAttribute="right"
               secondItem="timestamp-label" secondAttribute="right" constant="16"/>
</constraints>
```

**Correct (leading and trailing attributes):**

```xml
<constraints>
    <constraint firstItem="profile-image" firstAttribute="leading"
               secondItem="cell-content" secondAttribute="leading" constant="16"/>
    <constraint firstItem="username-label" firstAttribute="leading"
               secondItem="profile-image" secondAttribute="trailing" constant="12"/>
    <constraint firstItem="cell-content" firstAttribute="trailing"
               secondItem="timestamp-label" secondAttribute="trailing" constant="16"/>
</constraints>
```

**When NOT to use leading/trailing:**

- Constraints tied to a physical screen edge regardless of language direction (e.g., a camera viewfinder overlay that must stay on the literal left side)

Reference: [Auto Layout Guide - Working with Constraints in Interface Builder](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithConstraintsinInterfaceBuidler.html)
