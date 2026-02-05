---
title: Use SF Symbols for System Icons
impact: HIGH
impactDescription: consistent with iOS, automatic scaling, supports Dynamic Type
tags: view, swiftui, sf-symbols, icons, images, design
---

## Use SF Symbols for System Icons

SF Symbols are Apple's icon library with over 5,000 symbols. Use `Image(systemName:)` for consistent, scalable icons that match system appearance and support Dynamic Type.

**Incorrect (custom icon images):**

```swift
// Custom images don't scale or adapt
Image("custom-plus-icon")
    .resizable()
    .frame(width: 24, height: 24)

// Asset-based icons don't match system style
Image("settings-gear")
```

**Correct (SF Symbols):**

```swift
// Basic SF Symbol
Image(systemName: "globe")

// Scaled with text
Image(systemName: "star.fill")
    .imageScale(.large)

// Colored
Image(systemName: "heart.fill")
    .foregroundStyle(.red)

// In buttons and labels
Button {
    addItem()
} label: {
    Label("Add", systemImage: "plus")
}

// Multiple colors
Image(systemName: "cloud.sun.fill")
    .symbolRenderingMode(.multicolor)

// Variable value (iOS 16+)
Image(systemName: "speaker.wave.3.fill", variableValue: 0.7)

// Toolbar items
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        Button("Add", systemImage: "plus") {
            showAddSheet = true
        }
    }
}
```

**Finding SF Symbols:**
- Download SF Symbols app from Apple
- Search by name or category
- Check availability by iOS version
- Use symbol variants: `.fill`, `.circle`, `.square`

Reference: [Develop in Swift Tutorials - Hello, SwiftUI](https://developer.apple.com/tutorials/develop-in-swift/hello-swiftui)
