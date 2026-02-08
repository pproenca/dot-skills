---
title: Use Readable Content Guide for Text on Large Screens
impact: MEDIUM
impactDescription: prevents 100+ character line lengths on iPad
tags: adapt, readable-content-guide, iPad, typography
---

## Use Readable Content Guide for Text on Large Screens

Constraining text labels and text views to the superview's leading and trailing edges on iPad produces line lengths that exceed 100 characters, which drastically reduces readability. UIKit's `readableContentGuide` automatically narrows the content width to an optimal reading measure based on the current font size and screen width.

**Incorrect (text spans full width of iPad screen):**

```xml
<!-- Text stretches edge-to-edge on iPad Pro 12.9" — ~150 characters per line -->
<label id="articleBody" numberOfLines="0"
       translatesAutoresizingMaskIntoConstraints="NO">
    <constraints>
        <constraint firstItem="articleBody" firstAttribute="leading"
                    secondItem="safeArea" secondAttribute="leading"
                    constant="16" id="body-lead"/>
        <constraint firstItem="safeArea" firstAttribute="trailing"
                    secondItem="articleBody" secondAttribute="trailing"
                    constant="16" id="body-trail"/>
    </constraints>
</label>
```

**Correct (constrain to readableContentGuide for optimal line length):**

```xml
<!-- readableContentGuide caps line width to ~75 characters on iPad -->
<label id="articleBody" numberOfLines="0"
       translatesAutoresizingMaskIntoConstraints="NO">
    <constraints>
        <constraint firstItem="articleBody" firstAttribute="leading"
                    secondItem="readableContentGuide" secondAttribute="leading"
                    id="body-lead"/>
        <constraint firstItem="readableContentGuide" firstAttribute="trailing"
                    secondItem="articleBody" secondAttribute="trailing"
                    id="body-trail"/>
    </constraints>
</label>
```

In Interface Builder, select the constraint and check **"Relative to margin"** then switch the item from "Safe Area" to **"Readable Content Guide"** in the attribute inspector.

**When NOT to use:**
- Full-bleed images, maps, or media players should still pin to the superview or safe area edges
- Grid layouts where items fill the available width intentionally

**Reference:**
- [Apple: UIView.readableContentGuide](https://developer.apple.com/documentation/uikit/uiview/1622644-readablecontentguide)
