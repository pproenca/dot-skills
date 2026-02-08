---
title: Avoid Fixed Width and Height Constraints
impact: CRITICAL
impactDescription: prevents layout breakage across all device sizes
tags: layout, constraints, dimensions, intrinsic-content-size
---

## Avoid Fixed Width and Height Constraints

Fixed width and height constraints force views to a single pixel size, causing truncation on smaller screens and wasted space on larger ones. Views with intrinsic content size (labels, buttons, images) should size themselves based on content and be positioned with edge constraints instead.

**Incorrect (fixed width constraint on a label):**

```xml
<label id="greeting-label" text="Welcome back, Alexander">
    <rect key="frame" x="87" y="200" width="200" height="21"/>
    <constraints>
        <!-- Forces label to exactly 200pt regardless of content or screen -->
        <constraint firstAttribute="width" constant="200"/>
    </constraints>
</label>
```

**Correct (leading and trailing constraints with intrinsic content size):**

```xml
<label id="greeting-label" text="Welcome back, Alexander">
    <rect key="frame" x="16" y="200" width="343" height="21"/>
    <constraints>
        <constraint firstItem="greeting-label" firstAttribute="leading"
                   secondItem="content-view" secondAttribute="leading" constant="16"/>
        <constraint firstItem="content-view" firstAttribute="trailing"
                   secondItem="greeting-label" secondAttribute="trailing" constant="16"/>
    </constraints>
</label>
```

**When NOT to use intrinsic sizing:**

- Fixed-size icons or avatars (e.g., a 44x44pt tap target)
- Separator lines requiring a 1pt or 0.5pt height
- Views without intrinsic content size that need explicit dimensions

Reference: [Auto Layout Guide - Intrinsic Content Size](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/ViewswithIntrinsicContentSize.html)
