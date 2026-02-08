---
title: Review Storyboard Diffs as Source Code Before Committing
impact: MEDIUM
impactDescription: reduces storyboard diff noise by 80-90%
tags: vcs, diff, source-code, review
---

## Review Storyboard Diffs as Source Code Before Committing

Xcode's Interface Builder rewrites storyboard XML on every save, even when the developer made no intentional changes. Opening a storyboard, scrolling the canvas, or selecting an element can reorder XML attributes, update `translatesAutoresizingMaskIntoConstraints`, change `rect` frame values, or bump `toolsVersion`. Committing these noise changes buries real modifications and makes future git blame useless.

**Incorrect (blindly committing all IB-generated changes):**

```xml
<!-- git diff shows 47 changed lines, but developer only added one label -->
-    <rect key="frame" x="16" y="200" width="343" height="44"/>
+    <rect key="frame" x="16" y="200" width="343.00000000000006" height="44"/>

-    <constraint firstItem="title-label" firstAttribute="top"
-               secondItem="safe-area" secondAttribute="top" constant="200"/>
+    <constraint firstItem="title-label" firstAttribute="top"
+               secondItem="safe-area" secondAttribute="top" constant="200.00000000000003"/>

<!-- Unrelated toolsVersion bump -->
-    <document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB"
-              version="3.0" toolsVersion="21701">
+    <document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB"
+              version="3.0" toolsVersion="22505">
```

**Correct (review XML source, stage only intentional changes):**

Right-click the storyboard in Xcode's Project Navigator and select "Open As > Source Code" to inspect the raw XML before committing. Then use `git add -p` to stage only the meaningful hunks:

```bash
# Review the full diff first
git diff Checkout.storyboard

# Interactively stage only intentional changes
git add -p Checkout.storyboard
```

The intentional change in isolation:

```xml
<!-- Only the new label and its constraints are staged -->
<label id="discount-label" text="20% off"
       textAlignment="center" lineBreakMode="tailTruncation">
    <rect key="frame" x="16" y="252" width="343" height="21"/>
    <fontDescription key="fontDescription" style="UICTFontTextStyleSubheadline"/>
</label>
<constraint firstItem="discount-label" firstAttribute="top"
           secondItem="price-label" secondAttribute="bottom" constant="8"/>
```

**Benefits:**

- git blame remains useful because each line traces to a deliberate change
- Pull request reviewers see only real modifications, not IB noise
- Floating-point rect drift is caught before it enters the repository
