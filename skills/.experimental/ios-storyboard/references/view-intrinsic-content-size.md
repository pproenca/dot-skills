---
title: Rely on Intrinsic Content Size for Standard UIKit Controls
impact: MEDIUM
impactDescription: eliminates redundant width/height constraints
tags: view, intrinsic-size, constraints, uikit
---

## Rely on Intrinsic Content Size for Standard UIKit Controls

UILabel, UIButton, UIImageView, UISwitch, and UITextField all report an intrinsic content size based on their text, image, or fixed dimensions. Adding explicit width and height constraints on these controls duplicates what the layout engine already knows, creates maintenance overhead when content changes, and prevents Dynamic Type from resizing text naturally.

**Incorrect (explicit width and height on a UIButton):**

```xml
<button id="checkout-btn" buttonType="system">
    <rect key="frame" x="16" y="400" width="343" height="50"/>
    <state key="normal" title="Proceed to Checkout"/>
    <constraints>
        <!-- Redundant: UIButton already sizes itself from its title -->
        <constraint firstAttribute="width" constant="343"/>
        <constraint firstAttribute="height" constant="50"/>
    </constraints>
</button>
```

**Correct (position-only constraints, intrinsic size handles dimensions):**

```xml
<button id="checkout-btn" buttonType="system">
    <rect key="frame" x="16" y="400" width="343" height="50"/>
    <state key="normal" title="Proceed to Checkout"/>
    <fontDescription key="fontDescription" style="UICTFontTextStyleBody"/>
    <constraints>
        <constraint firstAttribute="height" constant="50" identifier="min-tap-target"/>
    </constraints>
</button>
```

**Alternative:**

When a minimum tap target height is required (44pt per Apple HIG), set a `>=` height constraint instead of an exact value. This allows Dynamic Type to grow the button beyond 44pt while enforcing a floor:

```xml
<constraint firstAttribute="height" relation="greaterThanOrEqual"
            constant="44" identifier="min-tap-target"/>
```

Controls with intrinsic content size: UILabel, UIButton, UIImageView (when image is set), UISwitch, UITextField, UISegmentedControl, UISlider, UIActivityIndicatorView.

Reference: [Intrinsic Content Size](https://developer.apple.com/documentation/uikit/uiview/1622600-intrinsiccontentsize)
