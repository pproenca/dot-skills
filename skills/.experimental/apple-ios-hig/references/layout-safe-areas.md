---
title: Respect Safe Area Insets
impact: CRITICAL
impactDescription: prevents content from being obscured by notch, Dynamic Island, or home indicator
tags: layout, safe-area, notch, dynamic-island
---

## Respect Safe Area Insets

Always respect safe area insets to prevent content from being obscured by the notch, Dynamic Island, status bar, or home indicator. Use `safeAreaInset` modifiers rather than manual padding.

**Incorrect (content hidden behind system UI):**

```swift
// Content goes under notch/Dynamic Island
VStack {
    Text("Title") // May be under notch
    List { /* content */ }
}
.ignoresSafeArea()

// Manual padding guesses at insets
VStack {
    Text("Title")
        .padding(.top, 44) // Wrong on different devices
}
```

**Correct (respects all device safe areas):**

```swift
// Automatic safe area respect (default)
VStack {
    Text("Title")
    List { /* content */ }
}
// No modifier needed - safe areas respected by default

// Background extends, content stays safe
VStack {
    Text("Title")
    List { /* content */ }
}
.background(Color.blue.ignoresSafeArea()) // Background extends
// Content still respects safe area

// Custom safe area inset
List { /* content */ }
    .safeAreaInset(edge: .bottom) {
        Button("Action") { }
            .frame(maxWidth: .infinity)
    }
```

**Safe area values by device:**
- iPhone with notch: ~47pt top, 34pt bottom
- iPhone with Dynamic Island: ~59pt top, 34pt bottom
- iPhone SE: ~20pt top (status bar only), 0pt bottom

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
