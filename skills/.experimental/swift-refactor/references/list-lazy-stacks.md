---
title: Replace VStack/HStack with LazyVStack/LazyHStack for Unbounded Content
impact: MEDIUM
impactDescription: lazy stacks instantiate only visible views — O(visible) vs O(N) memory and CPU
tags: list, lazy, stack, performance, scrollview
---

## Replace VStack/HStack with LazyVStack/LazyHStack for Unbounded Content

`VStack` and `HStack` inside a `ScrollView` instantiate ALL child views immediately, even those offscreen. For unbounded or large content, this means O(N) memory allocation and body evaluations at load time. `LazyVStack` and `LazyHStack` instantiate views on demand as they scroll into the visible area.

**Incorrect (VStack instantiates all 1000 items at once):**

```swift
struct FeedView: View {
    @State var viewModel: FeedViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // All 1000 PostCard views created immediately
                // Massive memory spike and slow initial render
                ForEach(viewModel.posts) { post in
                    PostCard(post: post)
                }
            }
        }
    }
}
```

**Correct (LazyVStack creates views on demand):**

```swift
struct FeedView: View {
    @State var viewModel: FeedViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Views created as they scroll into view
                // O(visible) memory — typically 10-20 views at a time
                ForEach(viewModel.posts) { post in
                    PostCard(post: post)
                }
            }
        }
    }
}
```

**When to use eager stacks:** Use `VStack`/`HStack` when the content count is known and small (< 20 items), or when you need the full layout calculated upfront (e.g., for `matchedGeometryEffect`).

Reference: [Lazy Stacks](https://developer.apple.com/documentation/swiftui/creating-performant-scrollable-stacks)
