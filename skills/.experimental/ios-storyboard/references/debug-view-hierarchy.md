---
title: Use Debug View Hierarchy to Inspect Layout Issues
impact: LOW-MEDIUM
impactDescription: identifies constraint issues 5-10x faster than log inspection
tags: debug, view-hierarchy, constraints, xcode
---

## Use Debug View Hierarchy to Inspect Layout Issues

Scrolling through Auto Layout constraint error logs in the console forces you to mentally reconstruct the view tree from memory addresses, which is error-prone and slow. Xcode's Debug View Hierarchy renders a 3D-explorable model of the live view tree, highlighting conflicting or ambiguous constraints in place and letting you inspect every frame, constraint, and priority visually.

**Incorrect (reading raw constraint logs in the console):**

```swift
// Attempting to debug layout by parsing console output
// Console prints walls of text like:
//   Unable to simultaneously satisfy constraints.
//   (
//     "<NSLayoutConstraint:0x600003a1c230 UILabel:0x7fa3b2d08e00.top == UIView:0x7fa3b2d04a10.top + 16>",
//     "<NSLayoutConstraint:0x600003a1c2d0 UILabel:0x7fa3b2d08e00.top == UIView:0x7fa3b2d04a10.top + 24>",
//     ...
//   )
// Developer tries to match memory addresses manually to find the broken view
func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    for subview in view.subviews {
        print("View: \(subview), frame: \(subview.frame)")
    }
}
```

**Correct (use Debug View Hierarchy for visual constraint inspection):**

```swift
// 1. Run the app on simulator or device
// 2. Xcode menu: Debug > View Debugging > Capture View Hierarchy
// 3. In the 3D view, click any view to see its constraints in the inspector
// 4. Purple constraint indicators show conflicts directly on the view

// For programmatic inspection in LLDB, pause execution and run:
//   (lldb) expr -l objc -- [[UIWindow keyWindow] _autolayoutTrace]
//   (lldb) expr -l objc -- [0x7fa3b2d08e00 _constraintsAffectingLayoutForAxis:0]
```

**When NOT to use:**

- For constraints created purely in code with no storyboard involvement, breakpoint-based LLDB inspection may be faster than capturing the full hierarchy.

**Benefits:**

- Visually pinpoints the exact view causing constraint conflicts without decoding memory addresses
- Shows clipped or overlapping views that are invisible in the running app
- Displays constraint priorities and installed size class variants inline

Reference: [Debugging Auto Layout](https://developer.apple.com/documentation/uikit/uiview/debugging_auto_layout)
