---
title: Use Semantic Colors for Automatic Dark Mode
impact: CRITICAL
impactDescription: ensures automatic adaptation to light/dark modes
tags: found, dark-mode, semantic, theming
---

## Use Semantic Colors for Automatic Dark Mode

Use iOS semantic colors (like `systemBackground`, `label`, `secondaryLabel`) instead of hardcoded colors. Semantic colors automatically adapt to light and dark modes without additional code.

**Incorrect (hardcoded colors break in dark mode):**

```swift
// SwiftUI
Text("Hello")
    .foregroundColor(Color.black) // Won't adapt to dark mode
    .background(Color.white)      // Harsh in dark mode

// UIKit
label.textColor = UIColor.black
view.backgroundColor = UIColor.white
```

**Correct (semantic colors adapt automatically):**

```swift
// SwiftUI
Text("Hello")
    .foregroundColor(.primary)    // Adapts to light/dark
    .background(Color(.systemBackground))

// UIKit
label.textColor = UIColor.label
view.backgroundColor = UIColor.systemBackground
```

**Available semantic colors:**
- Labels: `label`, `secondaryLabel`, `tertiaryLabel`, `quaternaryLabel`
- Backgrounds: `systemBackground`, `secondarySystemBackground`, `tertiarySystemBackground`
- Fills: `systemFill`, `secondarySystemFill`, `tertiarySystemFill`
- Groups: `systemGroupedBackground`, `secondarySystemGroupedBackground`

Reference: [Color - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/color)
