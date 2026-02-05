---
title: Choose Grid vs LazyVGrid by Data Size
impact: HIGH
impactDescription: prevents memory waste or layout issues from wrong grid type
tags: comp, grid, lazyvgrid, lazyhgrid, layout, performance
---

## Choose Grid vs LazyVGrid by Data Size

Grid loads all items immediately. LazyVGrid loads on demand. Use Grid for small fixed layouts, LazyVGrid for dynamic data.

**Incorrect (Grid for large dynamic data):**

```swift
struct PhotoGallery: View {
    let photos: [Photo]  // Could be hundreds

    var body: some View {
        ScrollView {
            Grid {  // Loads ALL photos immediately
                ForEach(photos) { photo in
                    GridRow {
                        PhotoThumbnail(photo: photo)
                    }
                }
            }
            // Massive memory usage, slow initial load
        }
    }
}
```

**Correct (LazyVGrid for dynamic data):**

```swift
struct PhotoGallery: View {
    let photos: [Photo]

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 2)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(photos) { photo in
                    PhotoThumbnail(photo: photo)
                        .aspectRatio(1, contentMode: .fill)
                }
            }
            // Only visible photos in memory
        }
    }
}
```

**Use Grid for small fixed layouts:**

```swift
struct QuickActionsGrid: View {
    let actions = QuickAction.defaults  // 6-9 items

    var body: some View {
        Grid(horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
                ActionButton(action: actions[0])
                ActionButton(action: actions[1])
                ActionButton(action: actions[2])
            }
            GridRow {
                ActionButton(action: actions[3])
                ActionButton(action: actions[4])
                ActionButton(action: actions[5])
            }
        }
    }
}
```

**Decision matrix:**

| Scenario | Use |
|----------|-----|
| Calculator buttons | Grid |
| Settings quick actions | Grid |
| Photo gallery | LazyVGrid |
| Product catalog | LazyVGrid |

Reference: [Apple Developer - LazyVGrid](https://developer.apple.com/documentation/swiftui/lazyvgrid)
