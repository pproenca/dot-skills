---
title: "Use LazyVGrid for Scrollable Grid Layouts"
impact: CRITICAL
impactDescription: "lazy grids create views on demand, handling thousands of items without memory spikes"
tags: layout, grids, lazy-loading, performance, scrolling
---

## Use LazyVGrid for Scrollable Grid Layouts

Building grids from nested HStacks inside a VStack creates every single view upfront, regardless of whether it is on screen. For a gallery with hundreds or thousands of items, this consumes excessive memory and causes visible frame drops on scroll. LazyVGrid only instantiates views that are currently visible, keeping memory flat and scrolling smooth.

**Incorrect (nested stacks create all views upfront, causing memory spikes):**

```swift
struct PhotoGalleryView: View {
    let photoAssets: [PhotoAsset]

    var body: some View {
        ScrollView {
            VStack(spacing: 4) {
                ForEach(0..<(photoAssets.count / 3), id: \.self) { rowIndex in
                    HStack(spacing: 4) {
                        ForEach(0..<3) { columnIndex in
                            let index = rowIndex * 3 + columnIndex
                            if index < photoAssets.count {
                                AsyncImage(url: photoAssets[index].thumbnailURL)
                                    .frame(width: 120, height: 120) // hardcoded, won't adapt
                                    .clipped()
                            }
                        }
                    }
                }
            }
        }
    }
}
```

**Correct (LazyVGrid creates views on demand with adaptive columns):**

```swift
struct PhotoGalleryView: View {
    let photoAssets: [PhotoAsset]

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 4) // adapts column count to screen width
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(photoAssets) { photoAsset in
                    AsyncImage(url: photoAsset.thumbnailURL)
                        .frame(minHeight: 100)
                        .clipped()
                }
            }
            .padding(.horizontal, 4)
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
