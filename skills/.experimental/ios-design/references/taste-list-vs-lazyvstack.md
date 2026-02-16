---
title: Choose List When You Need System Features, LazyVStack for Custom Layouts
impact: HIGH
impactDescription: saves 500+ lines of gesture and state code — List provides swipe actions, selection, edit mode, and separators for free, reducing custom UI code to 0 lines vs reimplementing 5 system behaviors from scratch
tags: taste, list, lazyvstack, kocienda-taste, edson-conviction, component
---

## Choose List When You Need System Features, LazyVStack for Custom Layouts

Kocienda's taste is the ability to look at two valid options and choose the one that's right for the context. `List` and `LazyVStack` both display scrollable content, but they serve fundamentally different purposes. This is a taste decision — choosing wrong means either reimplementing system behavior from scratch or fighting framework constraints for the rest of the feature's life. Edson's conviction demands committing fully to one approach rather than hedging.

**Incorrect (using LazyVStack when you need system features — reimplements 500+ lines):**

```swift
struct InboxView: View {
    @State private var messages: [Message] = []

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(messages) { message in
                    MessageRow(message: message)
                    Divider() // Manual dividers
                }
            }
        }
        // No swipe actions, no selection, no edit mode
        // Must reimplement all of these manually
    }
}
```

**Correct (List provides swipe actions, selection, and edit mode automatically):**

```swift
struct InboxView: View {
    @State private var messages: [Message] = []

    var body: some View {
        List {
            ForEach(messages) { message in
                NavigationLink(value: message) {
                    MessageRow(message: message)
                }
            }
            .onDelete { indexSet in
                messages.remove(atOffsets: indexSet)
            }
            .onMove { from, to in
                messages.move(fromOffsets: from, toOffset: to)
            }
        }
        .listStyle(.insetGrouped)
    }
}
```

**Use List when you need system behaviors:**

```swift
struct InboxView: View {
    @State private var messages: [Message] = []

    var body: some View {
        List {
            ForEach(messages) { message in
                NavigationLink(value: message) {
                    MessageRow(message: message)
                }
            }
            .onDelete { indexSet in
                messages.remove(atOffsets: indexSet)
            }
            .onMove { from, to in
                messages.move(fromOffsets: from, toOffset: to)
            }
        }
        .listStyle(.insetGrouped)
    }
}
// List gives you: swipe actions, selection, editing mode,
// separator management, section headers, pull-to-refresh
```

**Use LazyVStack when you need custom visual design:**

```swift
struct PhotoFeedView: View {
    let posts: [Post]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(posts) { post in
                    PostCard(post: post)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
// LazyVStack gives you: full visual control, custom spacing,
// no separator constraints, lazy loading, any background
```

**Decision framework:**
| Need | Choose | Why |
|------|--------|-----|
| Swipe actions | `List` | Built-in `.swipeActions()` |
| Selection (single/multi) | `List` | Built-in `.selection()` |
| Edit mode (reorder, delete) | `List` | Built-in `.onMove`, `.onDelete` |
| Section headers/footers | `List` | Built-in `Section` support |
| Custom card layouts | `LazyVStack` | No cell chrome to fight |
| Full-bleed images | `LazyVStack` | No inset constraints |
| Mixed content types | `LazyVStack` | No row height restrictions |
| Pull to refresh | Either | `.refreshable` works on both |

**When NOT to overthink:** For simple settings screens and standard data lists, `List` is almost always correct. Only reach for `LazyVStack` when `List`'s visual constraints block your design.

Reference: [Lists and tables - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/lists-and-tables)
