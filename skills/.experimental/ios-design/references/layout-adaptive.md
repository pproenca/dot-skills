---
title: Use Adaptive Layouts for Different Size Classes
impact: HIGH
impactDescription: ensures proper display across iPhone and iPad in all orientations
tags: layout, adaptive, size-class, responsive
---

## Use Adaptive Layouts for Different Size Classes

Design layouts that adapt to horizontal and vertical size classes. Use `@Environment(\.horizontalSizeClass)` to adjust layouts between compact (iPhone) and regular (iPad) widths.

**Incorrect (fixed layout ignores device capabilities):**

```swift
// Same layout everywhere - wastes iPad space
HStack {
    SidebarView()
        .frame(width: 250)
    ContentView()
}
// Shows sidebar on iPhone where it shouldn't
```

**Correct (adaptive based on size class):**

```swift
struct AdaptiveView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .regular {
            // iPad: Side-by-side layout
            HStack(spacing: 0) {
                SidebarView()
                    .frame(width: 320)
                ContentView()
            }
        } else {
            // iPhone: Navigation stack
            NavigationStack {
                ContentView()
            }
        }
    }
}

// Using NavigationSplitView (preferred)
NavigationSplitView {
    SidebarView()
} content: {
    ContentListView()
} detail: {
    DetailView()
}
// Automatically adapts to device
```

**Size class combinations:**
| Device | Horizontal | Vertical |
|--------|-----------|----------|
| iPhone Portrait | Compact | Regular |
| iPhone Landscape | Compact* | Compact |
| iPad Portrait | Regular | Regular |
| iPad Landscape | Regular | Regular |

*iPhone Pro Max has Regular horizontal in landscape.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
