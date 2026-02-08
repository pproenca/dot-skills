---
title: Set Content Hugging and Compression Resistance Priorities
impact: HIGH
impactDescription: eliminates ambiguous layout warnings
tags: layout, content-hugging, compression-resistance, priorities
---

## Set Content Hugging and Compression Resistance Priorities

When two views with intrinsic content size share the same axis and space is insufficient or excessive, Auto Layout must decide which view stretches or compresses. With default priorities (hugging=250, compression resistance=750), the layout is ambiguous and Auto Layout picks arbitrarily, producing Xcode warnings and inconsistent results across OS versions.

**Incorrect (both labels use default priorities, layout is ambiguous):**

```xml
<label id="field-label" text="Email Address">
    <rect key="frame" x="16" y="100" width="120" height="21"/>
    <!-- Default contentHuggingPriority horizontal=250 -->
    <!-- Default contentCompressionResistancePriority horizontal=750 -->
</label>
<label id="field-value" text="user@example.com">
    <rect key="frame" x="144" y="100" width="200" height="21"/>
    <!-- Same defaults: Auto Layout cannot decide which label stretches -->
</label>
```

**Correct (explicit priorities resolve ambiguity):**

```xml
<label id="field-label" text="Email Address">
    <rect key="frame" x="16" y="100" width="120" height="21"/>
    <contentHuggingPriority key="horizontal" value="252"/>
    <contentCompressionResistancePriority key="horizontal" value="751"/>
</label>
<label id="field-value" text="user@example.com">
    <rect key="frame" x="144" y="100" width="200" height="21"/>
    <!-- Keeps defaults (hugging=250): this label stretches to fill space -->
</label>
```

**Alternative (set in code for dynamic cases):**

```swift
fieldLabel.setContentHuggingPriority(.defaultLow + 2, for: .horizontal)
fieldLabel.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
```

Reference: [Auto Layout Guide - Intrinsic Content Size](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/ViewswithIntrinsicContentSize.html)
