---
title: Design Helpful Empty States
impact: MEDIUM
impactDescription: guides users on how to populate empty screens
tags: feed, empty-state, onboarding, guidance
---

## Design Helpful Empty States

Empty states should explain why the screen is empty and guide users on how to add content. Never show a blank screen or just "No items."

**Incorrect (unhelpful empty states):**

```swift
// Just text
if items.isEmpty {
    Text("No items")
}

// Completely blank
List(items) { item in
    ItemRow(item: item)
}
// When empty, shows nothing

// Error-like empty state
if favorites.isEmpty {
    Text("Error: No favorites found")
        .foregroundColor(.red)
}
```

**Correct (helpful empty states):**

```swift
// ContentUnavailableView (iOS 17+)
if items.isEmpty {
    ContentUnavailableView(
        "No Items Yet",
        systemImage: "tray",
        description: Text("Items you add will appear here.")
    )
}

// With action button
if favorites.isEmpty {
    ContentUnavailableView {
        Label("No Favorites", systemImage: "heart.slash")
    } description: {
        Text("Tap the heart on items you love to save them here.")
    } actions: {
        Button("Browse Items") {
            selectedTab = .browse
        }
        .buttonStyle(.borderedProminent)
    }
}

// Search empty state
if searchResults.isEmpty && !searchText.isEmpty {
    ContentUnavailableView.search(text: searchText)
}

// Custom empty state
if orders.isEmpty {
    VStack(spacing: 16) {
        Image(systemName: "bag")
            .font(.system(size: 64))
            .foregroundColor(.secondary)

        Text("No Orders Yet")
            .font(.headline)

        Text("When you place an order, it will appear here.")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)

        Button("Start Shopping") {
            selectedTab = .shop
        }
        .buttonStyle(.borderedProminent)
    }
    .padding()
}
```

**Empty state guidelines:**
- Use relevant SF Symbol icon
- Explain why it's empty
- Provide action to add content
- Don't make it feel like an error
- Match the tone of your app
- Consider first-run vs later empty

Reference: [Feedback - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/feedback)
