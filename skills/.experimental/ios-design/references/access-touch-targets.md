---
title: Ensure Minimum 44pt Touch Targets
impact: HIGH
impactDescription: "prevents 30-40% of tap errors on small targets; Apple requires 44pt minimum"
tags: access, touch, tap, target-size, buttons
---

## Ensure Minimum 44pt Touch Targets

Apple requires all interactive elements to have a minimum 44x44pt touch target. Smaller targets cause frequent mis-taps and are inaccessible to users with motor impairments.

**Incorrect (tiny touch targets):**

```swift
// Small icon button with no padding
Button {
    dismiss()
} label: {
    Image(systemName: "xmark")
        .font(.caption) // ~12pt, too small to tap reliably
}

// Text-only button too small
Button("Edit") { editProfile() }
    .font(.caption2) // Touch target smaller than 44pt
```

**Correct (minimum 44pt touch targets):**

```swift
// Icon button with adequate touch area
Button {
    dismiss()
} label: {
    Image(systemName: "xmark")
        .font(.body)
        .frame(minWidth: 44, minHeight: 44)
}

// Using contentShape to expand tap area
Button {
    selectItem()
} label: {
    HStack {
        Text(item.name)
        Spacer()
    }
}
.frame(minHeight: 44)
.contentShape(Rectangle()) // Entire row is tappable
```

**Common touch target patterns:**

```swift
// List rows are 44pt+ by default
List {
    ForEach(items) { item in
        Text(item.name) // List ensures minimum row height
    }
}

// Toolbar buttons get 44pt automatically
.toolbar {
    Button("Save") { save() } // System ensures target size
}

// Custom small elements need explicit sizing
Image(systemName: "info.circle")
    .frame(minWidth: 44, minHeight: 44)
    .contentShape(Rectangle())
    .onTapGesture { showInfo() }
```

Reference: [Accessibility - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
