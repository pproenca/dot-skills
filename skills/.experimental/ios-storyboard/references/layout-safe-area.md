---
title: Constrain Views to Safe Area Guides
impact: CRITICAL
impactDescription: prevents content hidden behind notch, Dynamic Island, and home indicator
tags: layout, safe-area, notch, dynamic-island
---

## Constrain Views to Safe Area Guides

The safe area insets account for the status bar, navigation bar, notch, Dynamic Island, and home indicator. Constraining to the superview edges instead of the safe area causes content to render behind system UI elements, making it untappable or invisible.

**Incorrect (constraints to superview edges):**

```xml
<viewController id="main-vc">
    <view key="view" id="root-view">
        <subviews>
            <label id="page-title" text="Account Settings">
                <rect key="frame" x="16" y="0" width="343" height="44"/>
            </label>
        </subviews>
        <constraints>
            <!-- Top constraint to superview hides label behind notch/Dynamic Island -->
            <constraint firstItem="page-title" firstAttribute="top"
                       secondItem="root-view" secondAttribute="top"/>
            <constraint firstItem="page-title" firstAttribute="leading"
                       secondItem="root-view" secondAttribute="leading" constant="16"/>
        </constraints>
    </view>
</viewController>
```

**Correct (constraints to safe area layout guide):**

```xml
<viewController id="main-vc">
    <view key="view" id="root-view">
        <viewLayoutGuide key="safeArea" id="safe-area"/>
        <subviews>
            <label id="page-title" text="Account Settings">
                <rect key="frame" x="16" y="59" width="343" height="44"/>
            </label>
        </subviews>
        <constraints>
            <constraint firstItem="page-title" firstAttribute="top"
                       secondItem="safe-area" secondAttribute="top"/>
            <constraint firstItem="page-title" firstAttribute="leading"
                       secondItem="safe-area" secondAttribute="leading" constant="16"/>
        </constraints>
    </view>
</viewController>
```

**Benefits:**

- Automatically adapts to all device form factors (iPhone SE through Pro Max)
- Handles landscape orientation where safe area insets shift
- Future-proofs against new hardware shapes

Reference: [Positioning Content Relative to the Safe Area](https://developer.apple.com/documentation/uikit/uiview/positioning_content_relative_to_the_safe_area)
