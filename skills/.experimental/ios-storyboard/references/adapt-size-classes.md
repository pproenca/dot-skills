---
title: Configure Constraints per Size Class Using Vary for Traits
impact: HIGH
impactDescription: eliminates device-specific storyboard duplication
tags: adapt, size-class, constraints, vary-for-traits
---

## Configure Constraints per Size Class Using Vary for Traits

Maintaining separate iPhone and iPad storyboards doubles the design surface, doubles the bug surface, and guarantees the two will drift out of sync. Interface Builder's "Vary for Traits" mode lets you install, uninstall, or change constraint constants per size class within a single storyboard file.

**Incorrect (duplicate storyboards for each device family):**

```xml
<!-- Main_iPhone.storyboard — must be kept in sync manually -->
<constraint firstItem="productImage" firstAttribute="width"
            constant="120" id="img-w-iphone"/>
<constraint firstItem="productImage" firstAttribute="height"
            constant="120" id="img-h-iphone"/>
<constraint firstItem="detailsStack" firstAttribute="leading"
            secondItem="safeArea" secondAttribute="leading"
            constant="16" id="stack-lead-iphone"/>

<!-- Main_iPad.storyboard — identical structure, different constants -->
<constraint firstItem="productImage" firstAttribute="width"
            constant="280" id="img-w-ipad"/>
<constraint firstItem="productImage" firstAttribute="height"
            constant="280" id="img-h-ipad"/>
<constraint firstItem="detailsStack" firstAttribute="leading"
            secondItem="safeArea" secondAttribute="leading"
            constant="40" id="stack-lead-ipad"/>
```

**Correct (single storyboard with size-class-specific constraint installations):**

```xml
<!-- Products.storyboard — compact width (iPhone portrait) -->
<constraint firstItem="productImage" firstAttribute="width"
            constant="120" id="img-w">
    <variation key="widthClass=compact" constant="120"/>
    <variation key="widthClass=regular" constant="280"/>
</constraint>

<constraint firstItem="productImage" firstAttribute="height"
            constant="120" id="img-h">
    <variation key="widthClass=compact" constant="120"/>
    <variation key="widthClass=regular" constant="280"/>
</constraint>

<constraint firstItem="detailsStack" firstAttribute="leading"
            secondItem="safeArea" secondAttribute="leading"
            constant="16" id="stack-lead">
    <variation key="widthClass=compact" constant="16"/>
    <variation key="widthClass=regular" constant="40"/>
</constraint>
```

**Benefits:**
- One storyboard to maintain instead of two, cutting design drift to zero
- Changes propagate to all device sizes automatically via trait variations
- Preview in Interface Builder by switching the simulated size class at the bottom bar
