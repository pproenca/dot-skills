---
title: Use Menus for Secondary Actions Without Cluttering the Interface
impact: MEDIUM
impactDescription: putting every action in the toolbar creates visual clutter — menus group 3-8 secondary actions behind a single tap point, keeping the primary interface clean
tags: product, menu, actions, edson-product-marketing, kocienda-demo, organization
---

## Use Menus for Secondary Actions Without Cluttering the Interface

Edson's "the product is the marketing" means the primary interface should be clean and focused — secondary actions exist but shouldn't compete for attention. A `Menu` groups related actions behind a single button (typically an ellipsis "..." icon), revealing them on tap. Kocienda's demo culture valued interfaces where the primary action was obvious at a glance; menus keep secondary actions available without cluttering the screen.

**Incorrect (all actions in toolbar — visual clutter):**

```swift
struct ArticleView: View {
    var body: some View {
        ScrollView { /* content */ }
            .toolbar {
                // Too many toolbar buttons — user can't find the primary action
                ToolbarItem { Button("Share", systemImage: "square.and.arrow.up") { } }
                ToolbarItem { Button("Bookmark", systemImage: "bookmark") { } }
                ToolbarItem { Button("Print", systemImage: "printer") { } }
                ToolbarItem { Button("Text Size", systemImage: "textformat.size") { } }
                ToolbarItem { Button("Report", systemImage: "flag") { } }
            }
    }
}
```

**Correct (primary action visible, secondary actions in menu):**

```swift
struct ArticleView: View {
    @State private var isBookmarked = false

    var body: some View {
        ScrollView { /* content */ }
            .toolbar {
                // Primary action stays visible
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isBookmarked.toggle()
                    } label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    }
                }

                // Secondary actions grouped in menu
                ToolbarItem {
                    Menu {
                        Button("Share", systemImage: "square.and.arrow.up") { share() }
                        Button("Print", systemImage: "printer") { printArticle() }
                        Button("Text Size", systemImage: "textformat.size") { adjustSize() }

                        Divider()

                        Button("Report Issue", systemImage: "flag", role: .destructive) {
                            report()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
    }
}
```

**Menu organization:**

```swift
Menu {
    // Group related actions
    Section("Share") {
        Button("Copy Link", systemImage: "link") { }
        Button("Share via...", systemImage: "square.and.arrow.up") { }
    }

    Section("Manage") {
        Button("Edit", systemImage: "pencil") { }
        Button("Move to...", systemImage: "folder") { }
    }

    // Destructive actions at the bottom, separated
    Section {
        Button("Delete", systemImage: "trash", role: .destructive) { }
    }
} label: {
    Image(systemName: "ellipsis.circle")
}
```

**Menu vs Context Menu:**
- `Menu` — triggered by tapping a visible button (explicit)
- `.contextMenu` — triggered by long-press (hidden, discoverable)
- Use Menu for actions the user will need regularly
- Use contextMenu for power-user shortcuts

**When NOT to use menus:** When there's only one secondary action (use a plain button). When actions are critical and time-sensitive (use visible buttons).

Reference: [Menus - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/menus)
