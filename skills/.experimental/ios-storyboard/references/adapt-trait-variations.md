---
title: Use Trait Variations for Font and Spacing Adjustments
impact: HIGH
impactDescription: eliminates per-device font overrides
tags: adapt, trait-variation, font, spacing, readability
---

## Use Trait Variations for Font and Spacing Adjustments

Hardcoding a single font size across all devices forces text to be either too small on iPad or too large on iPhone SE. Interface Builder's attribute variations let you set different font sizes, colors, and spacing values per size class, so typography adapts without a single line of code.

**Incorrect (one font size used everywhere):**

```xml
<!-- Same 14pt forced onto 4.7" iPhone and 12.9" iPad -->
<label id="articleTitle" text="Article Title">
    <fontDescription key="fontDescription" type="system" pointSize="14"/>
</label>

<label id="articleBody" text="Lorem ipsum...">
    <fontDescription key="fontDescription" type="system" pointSize="12"/>
</label>

<constraint firstItem="articleBody" firstAttribute="top"
            secondItem="articleTitle" secondAttribute="bottom"
            constant="8" id="title-body-spacing"/>
```

**Correct (trait-varied fonts and spacing that scale with device size):**

```xml
<label id="articleTitle" text="Article Title">
    <fontDescription key="fontDescription" type="system" pointSize="14"/>
    <variation key="widthClass=regular"
              value="fontDescription.pointSize=20"/>
</label>

<label id="articleBody" text="Lorem ipsum...">
    <fontDescription key="fontDescription" type="system" pointSize="12"/>
    <variation key="widthClass=regular"
              value="fontDescription.pointSize=17"/>
</label>

<constraint firstItem="articleBody" firstAttribute="top"
            secondItem="articleTitle" secondAttribute="bottom"
            constant="8" id="title-body-spacing">
    <variation key="widthClass=regular" constant="16"/>
</constraint>
```

**Benefits:**
- Typography meets Apple HIG minimum tap target and readability guidelines on every device
- No runtime code needed; Interface Builder previews show both variants instantly
- Spacing adjusts proportionally, preventing cramped layouts on large screens
