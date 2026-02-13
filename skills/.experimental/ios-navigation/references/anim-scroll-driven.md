---
title: Use onScrollGeometryChange for Scroll-Driven Transitions (iOS 18+)
impact: MEDIUM
impactDescription: enables pull-to-dismiss, parallax, and scroll-linked effects at 60fps
tags: anim, scroll, geometry, interactive, ios18
---

## Use onScrollGeometryChange for Scroll-Driven Transitions (iOS 18+)

The `.onScrollGeometryChange` modifier provides scroll offset and content geometry directly from the scroll view without `GeometryReader` workarounds. Using `GeometryReader` inside a `ScrollView` causes layout feedback loops, unexpected frame changes, and dropped frames because the reader's size depends on the scroll position which in turn depends on content size. The dedicated scroll geometry API avoids these issues entirely and runs at 60fps.

**Incorrect (GeometryReader inside ScrollView causes layout cycles):**

```swift
// BAD: GeometryReader inside ScrollView creates a layout feedback loop.
// The reader's frame changes with scroll position, which triggers
// re-layout, which changes the frame again. This causes stuttering
// and can drop to 30fps or below on complex views.
struct CollapsibleHeaderView: View {
    @State private var headerHeight: CGFloat = 250
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ScrollView {
            GeometryReader { proxy in
                // WRONG: reading minY here causes layout cycles
                Color.clear
                    .preference(
                        key: ScrollOffsetKey.self,
                        value: proxy.frame(in: .global).minY
                    )
            }
            .frame(height: 0)

            VStack(spacing: 0) {
                HeaderImage()
                    .frame(height: max(headerHeight + scrollOffset, 80))
                    .clipped()

                ContentList()
            }
        }
        .onPreferenceChange(ScrollOffsetKey.self) { value in
            scrollOffset = value // Triggers re-layout every frame
        }
    }
}
```

**Correct (onScrollGeometryChange for scroll-linked effects):**

```swift
struct CollapsibleHeaderView: View {
    @State private var scrollOffset: CGFloat = 0

    private let expandedHeight: CGFloat = 250
    private let collapsedHeight: CGFloat = 80

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HeaderImage()
                    .frame(height: currentHeaderHeight)
                    .clipped()
                    .opacity(headerOpacity)

                ContentList()
            }
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, newOffset in
            scrollOffset = newOffset
        }
    }

    private var currentHeaderHeight: CGFloat {
        let height = expandedHeight - scrollOffset
        return max(height, collapsedHeight)
    }

    private var headerOpacity: Double {
        let progress = scrollOffset / (expandedHeight - collapsedHeight)
        return max(1 - Double(progress) * 1.5, 0)
    }
}
```
