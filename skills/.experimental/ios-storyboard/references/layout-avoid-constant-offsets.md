---
title: Use Layout Margins Instead of Constant Offsets
impact: HIGH
impactDescription: eliminates manual spacing constants across devices
tags: layout, margins, spacing, system-spacing
---

## Use Layout Margins Instead of Constant Offsets

Hardcoding constant values (e.g., 16, 20) to superview edges creates inconsistent spacing that does not adapt to device size class or user accessibility settings. The system `layoutMarginsGuide` provides standard insets that adjust per device (16pt on iPhone SE, 20pt on larger iPhones) and respect the readable content guide for wide screens like iPad.

**Incorrect (hardcoded constant to superview edge):**

```xml
<constraints>
    <constraint firstItem="article-body" firstAttribute="leading"
               secondItem="root-view" secondAttribute="leading" constant="16"/>
    <constraint firstItem="root-view" firstAttribute="trailing"
               secondItem="article-body" secondAttribute="trailing" constant="16"/>
    <!-- Constant stays 16pt on all devices, too narrow on iPad -->
</constraints>
```

**Correct (constraint to layout margins guide):**

```xml
<view id="root-view">
    <viewLayoutGuide key="layoutMargins" id="margins-guide"/>
    <subviews>
        <textView id="article-body"/>
    </subviews>
    <constraints>
        <constraint firstItem="article-body" firstAttribute="leading"
                   secondItem="margins-guide" secondAttribute="leading"/>
        <constraint firstItem="margins-guide" firstAttribute="trailing"
                   secondItem="article-body" secondAttribute="trailing"/>
    </constraints>
</view>
```

**Alternative (readable content guide for text-heavy layouts):**

```xml
<viewLayoutGuide key="readableContentGuide" id="readable-guide"/>
<constraints>
    <constraint firstItem="article-body" firstAttribute="leading"
               secondItem="readable-guide" secondAttribute="leading"/>
    <constraint firstItem="readable-guide" firstAttribute="trailing"
               secondItem="article-body" secondAttribute="trailing"/>
</constraints>
```

Reference: [UIView.layoutMarginsGuide](https://developer.apple.com/documentation/uikit/uiview/1622651-layoutmarginsguide)
