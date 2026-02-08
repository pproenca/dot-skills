---
title: Set Initial View Controller Explicitly in Every Storyboard
impact: HIGH
impactDescription: prevents nil instantiation crashes
tags: arch, initial-view-controller, crash-prevention, storyboard
---

## Set Initial View Controller Explicitly in Every Storyboard

When a storyboard has no `initialViewController` attribute, calling `instantiateInitialViewController()` returns `nil`. Force-unwrapping that result -- or passing it to a navigation controller -- produces a crash with no useful error message. Every storyboard must declare exactly one initial view controller so that programmatic instantiation is always safe.

**Incorrect (missing initialViewController attribute):**

```xml
<!-- Checkout.storyboard — no initialViewController set -->
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB"
          version="3.0" toolsVersion="21701" targetRuntime="AppleSDK">
    <scenes>
        <scene sceneID="checkout-cart">
            <objects>
                <viewController id="CheckoutCartVC"
                                sceneMemberID="viewController"/>
            </objects>
        </scene>
    </scenes>
</document>
```

```swift
// This crashes at runtime — instantiateInitialViewController() returns nil
let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
let checkoutVC = storyboard.instantiateInitialViewController()!
// Fatal error: Unexpectedly found nil while unwrapping an Optional value
navigationController?.pushViewController(checkoutVC, animated: true)
```

**Correct (initialViewController attribute set on the document element):**

```xml
<!-- Checkout.storyboard — initialViewController points to the entry scene -->
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB"
          version="3.0" toolsVersion="21701" targetRuntime="AppleSDK"
          initialViewController="CheckoutCartVC">
    <scenes>
        <scene sceneID="checkout-cart">
            <objects>
                <viewController id="CheckoutCartVC"
                                sceneMemberID="viewController"/>
            </objects>
        </scene>
    </scenes>
</document>
```

```swift
let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
let checkoutVC = storyboard.instantiateInitialViewController()!
navigationController?.pushViewController(checkoutVC, animated: true)
```

**Alternative (safe unwrapping with guard):**

```swift
let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
guard let checkoutVC = storyboard.instantiateInitialViewController() else {
    assertionFailure("Checkout.storyboard is missing its initial view controller")
    return
}
navigationController?.pushViewController(checkoutVC, animated: true)
```
