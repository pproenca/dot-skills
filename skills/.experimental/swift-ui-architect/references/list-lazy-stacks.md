---
title: Use LazyVStack/LazyHStack for Unbounded Content
impact: MEDIUM
impactDescription: O(visible) vs O(N) view creation — 10-100× fewer views for large lists
tags: list, lazy, vstack, hstack, scroll-performance
---

## Use LazyVStack/LazyHStack for Unbounded Content

`VStack` and `HStack` create ALL child views immediately, even those offscreen. For any list with more than ~20 items or dynamic content of unknown size, use `LazyVStack`/`LazyHStack` inside a `ScrollView`. Lazy stacks only create views as they scroll into the visible area, reducing memory usage and initial render time from O(N) to O(visible).

**Incorrect (VStack with 500 items — all 500 views created immediately):**

```swift
struct MessageListView: View {
    @State var viewModel: MessageListViewModel

    var body: some View {
        ScrollView {
            // VStack creates ALL 500 MessageRow views at once
            // Even messages at the bottom that the user hasn't scrolled to yet
            // Initial render: ~500 view allocations, ~500 body evaluations
            VStack(spacing: 0) {
                ForEach(viewModel.messages) { message in
                    MessageRow(message: message)
                        .padding(.horizontal)
                }
            }
        }
    }
}

// With 500 messages:
// - Memory: all 500 views allocated simultaneously
// - Render time: O(500) — body evaluates for every message
// - Visible on screen: approximately 10 messages
// - Wasted work: 490 views created but invisible
```

**Correct (LazyVStack — only visible views created):**

```swift
struct MessageListView: View {
    @State var viewModel: MessageListViewModel

    var body: some View {
        ScrollView {
            // LazyVStack only creates views as they scroll into view
            // Initial render: ~10-15 views (visible + small buffer)
            LazyVStack(spacing: 0) {
                ForEach(viewModel.messages) { message in
                    MessageRow(message: message)
                        .padding(.horizontal)
                }
            }
        }
    }
}

// With 500 messages:
// - Memory: ~10-15 views allocated (visible + buffer)
// - Render time: O(visible) — only visible message bodies evaluate
// - As user scrolls: new views created, offscreen views may be released
// - Initial render is nearly instant regardless of total count
```

**When NOT to use lazy stacks:**

```swift
// Small, fixed-size lists (under ~20 items) — eager is cheaper than lazy overhead
struct SettingsView: View {
    var body: some View {
        ScrollView {
            // 8 items — VStack is fine, lazy overhead isn't worth it
            VStack(spacing: 12) {
                SettingsRow(title: "Account")
                SettingsRow(title: "Notifications")
                SettingsRow(title: "Privacy")
                SettingsRow(title: "Appearance")
                SettingsRow(title: "Storage")
                SettingsRow(title: "Language")
                SettingsRow(title: "About")
                SettingsRow(title: "Help")
            }
            .padding()
        }
    }
}
```

**Key differences:**
- `LazyVStack` defers view creation until scroll position demands it
- `LazyVStack` does NOT cache views — scrolling back may recreate them (use `@State` for persistence)
- `LazyVStack` with `pinnedViews: [.sectionHeaders]` supports sticky section headers

Reference: [Apple Documentation — Creating performant scrollable stacks](https://developer.apple.com/documentation/swiftui/creating-performant-scrollable-stacks)
