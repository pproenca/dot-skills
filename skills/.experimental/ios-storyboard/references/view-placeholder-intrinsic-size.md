---
title: Use Placeholder Intrinsic Size for Custom Views in Storyboard
impact: MEDIUM
impactDescription: eliminates Interface Builder constraint warnings for dynamic content
tags: view, placeholder, intrinsic-size, interface-builder
---

## Use Placeholder Intrinsic Size for Custom Views in Storyboard

Custom views that compute their size at runtime (e.g., a chart view or a dynamically loaded image container) trigger Interface Builder constraint warnings because IB cannot determine their dimensions at design time. Developers often add fixed-width and fixed-height constraints to silence the warnings, but these constraints override the runtime size and cause incorrect layouts. Setting the Intrinsic Size to "Placeholder" in the Size Inspector tells IB to assume a size for validation only, without generating any runtime constraints.

**Incorrect (fixed constraints added to silence IB warnings):**

```xml
<view contentMode="scaleToFill" id="chart-container"
      customClass="SalesChartView" customModule="Analytics">
    <rect key="frame" x="16" y="200" width="343" height="220"/>
    <constraints>
        <!-- Added only to silence IB; overrides runtime layout -->
        <constraint firstAttribute="width" constant="343"/>
        <constraint firstAttribute="height" constant="220"/>
    </constraints>
</view>
```

**Correct (placeholder intrinsic size removes IB warnings without runtime side effects):**

```xml
<view contentMode="scaleToFill" id="chart-container"
      customClass="SalesChartView" customModule="Analytics">
    <rect key="frame" x="16" y="200" width="343" height="220"/>
    <!-- Placeholder only: IB uses this for canvas rendering, not at runtime -->
    <userDefinedRuntimeAttributes>
        <userDefinedRuntimeAttribute type="size" keyPath="intrinsicContentSize">
            <size key="value" width="343" height="220"/>
        </userDefinedRuntimeAttribute>
    </userDefinedRuntimeAttributes>
</view>
```

To set this in Xcode: select the custom view, open the Size Inspector, and change the Intrinsic Size dropdown from "Default (System Defined)" to "Placeholder". Enter the design-time width and height. These values are stripped at build time and have no effect on the running app.

Reference: [Interface Builder Help: Setting Placeholder Constraints](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithConstraintsinInterfaceBuidler.html)
