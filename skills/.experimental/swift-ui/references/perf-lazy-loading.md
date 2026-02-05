---
title: Use Lazy Containers for Large Collections
impact: MEDIUM
impactDescription: loads only visible items, reduces memory by 90%+
tags: perf, lazy, lazyvstack, lazyhstack, memory
---

## Use Lazy Containers for Large Collections

Lazy containers (LazyVStack, LazyHStack, LazyVGrid) only create views for items currently on screen. Non-lazy containers create all views immediately.

**Incorrect (VStack loads all 1000 items):**

```swift
struct MessageHistory: View {
    let messages: [Message]  // 1000+ messages

    var body: some View {
        ScrollView {
            VStack {
                ForEach(messages) { message in
                    MessageRow(message: message)  // All 1000 created immediately
                }
            }
        }
    }
}
```

**Correct (LazyVStack loads on demand):**

```swift
struct MessageHistory: View {
    let messages: [Message]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(messages) { message in
                    MessageRow(message: message)  // Only visible rows created
                }
            }
        }
    }
}
```

**Memory comparison:**
- VStack with 1000 rows: ~1000 views in memory
- LazyVStack with 1000 rows: ~20 views in memory (visible + buffer)

**Lazy grid for galleries:**

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
                    AsyncImage(url: photo.thumbnailURL)
                        .aspectRatio(1, contentMode: .fill)
                }
            }
        }
    }
}
```

**When NOT to use Lazy:**
- Small, fixed collections (< 20 items)
- When you need simultaneous animations
- When using `.id()` modifier (can break lazy loading)

**Combining with pagination:**

```swift
LazyVStack {
    ForEach(items) { item in
        ItemRow(item: item)
    }

    if hasMoreItems {
        ProgressView()
            .onAppear { loadMoreItems() }
    }
}
```

Reference: [Creating Performant Scrollable Stacks](https://developer.apple.com/documentation/swiftui/creating-performant-scrollable-stacks)
