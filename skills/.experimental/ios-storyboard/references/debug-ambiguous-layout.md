---
title: Use hasAmbiguousLayout to Detect Constraint Problems at Runtime
impact: LOW-MEDIUM
impactDescription: prevents silent layout randomization on different devices
tags: debug, ambiguous-layout, constraints, runtime-checks
---

## Use hasAmbiguousLayout to Detect Constraint Problems at Runtime

Ambiguous layouts do not crash the app -- they silently pick an arbitrary frame, which means a view may appear correct on one device but shift unpredictably on another. Without an explicit runtime check, these bugs only surface when a user on a different screen size reports misaligned UI.

**Incorrect (no runtime detection of ambiguous constraints):**

```swift
class OrderSummaryViewController: UIViewController {
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        totalLabel.text = "$129.99"
        itemCountLabel.text = "3 items"
        // No check for ambiguous layout; views may render in wrong positions
        // and the issue goes unnoticed until a tester files a bug
    }
}
```

**Correct (assert on ambiguous layout in debug builds):**

```swift
class OrderSummaryViewController: UIViewController {
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        totalLabel.text = "$129.99"
        itemCountLabel.text = "3 items"
    }

    #if DEBUG
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for subview in view.subviews where subview.hasAmbiguousLayout {
            // Logs the view and animates it between valid positions
            print("AMBIGUOUS LAYOUT: \(subview)")
            subview.exerciseAmbiguityInLayout()
        }
    }
    #endif
}
```

**Alternative (recursive check for deep view hierarchies):**

```swift
#if DEBUG
extension UIView {
    func reportAmbiguousLayouts(depth: Int = 0) {
        if hasAmbiguousLayout {
            let indent = String(repeating: "  ", count: depth)
            print("\(indent)AMBIGUOUS: \(type(of: self)), frame: \(frame)")
        }
        subviews.forEach { $0.reportAmbiguousLayouts(depth: depth + 1) }
    }
}
#endif
```

**Benefits:**

- Surfaces ambiguous layouts immediately during development, not after release
- `exerciseAmbiguityInLayout()` visually animates between valid positions, making the problem obvious
- `#if DEBUG` ensures zero overhead in production builds

Reference: [hasAmbiguousLayout](https://developer.apple.com/documentation/uikit/uiview/hasambiguouslayout)
