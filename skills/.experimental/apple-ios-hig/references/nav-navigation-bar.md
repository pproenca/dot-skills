---
title: Use Navigation Bar for Hierarchical Navigation
impact: CRITICAL
impactDescription: enables standard back navigation and screen context
tags: nav, navigation-bar, hierarchy, back-button
---

## Use Navigation Bar for Hierarchical Navigation

Use navigation bars to show hierarchy and enable back navigation. Include a title, back button, and optional trailing actions. Never hide the back button.

**Incorrect (breaking navigation conventions):**

```swift
// No navigation bar - user is lost
VStack {
    Text("Detail View")
    // No way to go back on iPhone without gesture
}

// Custom back button that looks different
NavigationStack {
    DetailView()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("< Go Back") { } // Non-standard appearance
            }
        }
        .navigationBarBackButtonHidden() // Hides system back
}
```

**Correct (standard navigation bar):**

```swift
NavigationStack {
    List(items) { item in
        NavigationLink(value: item) {
            ItemRow(item: item)
        }
    }
    .navigationTitle("Items")
    .navigationDestination(for: Item.self) { item in
        ItemDetailView(item: item)
            .navigationTitle(item.name)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") { }
                }
            }
    }
}

// Large title for top-level screens
.navigationTitle("Home")
.navigationBarTitleDisplayMode(.large)

// Inline title for detail screens
.navigationTitle("Item Details")
.navigationBarTitleDisplayMode(.inline)
```

**Navigation bar guidelines:**
- Top-level screens: large title (`.large`)
- Detail screens: inline title (`.inline`)
- Always show back button (never hide without alternative)
- Keep trailing actions to 1-2 buttons
- Use standard system back chevron

Reference: [Navigation and search - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/navigation-and-search)
