---
title: Test Adaptive Layouts on All Device Size Classes
impact: MEDIUM-HIGH
impactDescription: prevents layout breakage on 4 size class combinations
tags: adapt, testing, size-class, device-matrix
---

## Test Adaptive Layouts on All Device Size Classes

Testing only on a single device (typically the developer's physical phone) hides layout breaks that surface on different screen sizes, orientations, and multitasking modes. Apple's review team tests on multiple devices, and constraint warnings or clipped content will trigger rejection.

**Incorrect (testing only on the most common device):**

```swift
// "It looks fine on my iPhone 15 Pro" — layout verified on one device only
//
// Untested scenarios:
// - iPhone SE (3rd gen): compact width, compact height in landscape
// - iPad Air in 1/3 Split View: compact width on a tablet
// - iPad Pro 12.9" full screen: regular width, regular height
// - iPhone 15 Pro Max landscape: compact height
```

**Correct (systematic testing across all four size class combinations):**

```swift
// Device size class test matrix — verify each combination in Xcode previews or simulators
//
// ┌──────────────────────────────┬───────────────┬────────────────┐
// │ Device / Mode                │ Width Class   │ Height Class   │
// ├──────────────────────────────┼───────────────┼────────────────┤
// │ iPhone SE portrait           │ Compact       │ Regular        │
// │ iPhone SE landscape          │ Compact       │ Compact        │
// │ iPhone 15 Pro Max portrait   │ Compact       │ Regular        │
// │ iPhone 15 Pro Max landscape  │ Regular       │ Compact        │
// │ iPad Air portrait            │ Regular       │ Regular        │
// │ iPad Air landscape           │ Regular       │ Regular        │
// │ iPad 1/3 Split View          │ Compact       │ Regular        │
// │ iPad 2/3 Split View          │ Regular       │ Regular        │
// │ iPad Slide Over              │ Compact       │ Regular        │
// └──────────────────────────────┴───────────────┴────────────────┘
//
// Minimum coverage: test at least one device from each unique
// (widthClass, heightClass) pair — that is 4 combinations.
```

**Alternative:**

Use Xcode's Preview canvas with multiple device configurations to verify layouts without launching simulators:

```swift
// In a SwiftUI preview host or UIViewControllerRepresentable wrapper
#Preview("Compact Width") {
    let storyboard = UIStoryboard(name: "Products", bundle: nil)
    return storyboard.instantiateInitialViewController()!
}
```

**Benefits:**
- Catches truncated labels, overlapping views, and broken constraints before submission
- Reduces App Store review rejections caused by layout issues on untested devices
- Builds confidence that size class variations work as designed
