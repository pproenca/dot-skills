---
title: Add Accessibility Labels to Interactive Elements
impact: MEDIUM
impactDescription: VoiceOver reads labels to screen reader users, unlabeled controls are invisible
tags: access, voiceover, accessibility-label, button, image
---

## Add Accessibility Labels to Interactive Elements

VoiceOver relies on accessibility labels to describe controls to users who cannot see the screen. When an interactive element like an icon button has no label, VoiceOver either skips it entirely or reads a meaningless default like "button," leaving the user unable to interact with your app.

**Incorrect (icon button without accessibility label):**

```swift
struct ItemRow: View {
    let item: GroceryItem

    var body: some View {
        HStack {
            Text(item.name)
            Spacer()
            Button(action: { deleteItem(item) }) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            Button(action: { toggleFavorite(item) }) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
            }
        }
    }
}
```

**Correct (descriptive label for each icon button):**

```swift
struct ItemRow: View {
    let item: GroceryItem

    var body: some View {
        HStack {
            Text(item.name)
            Spacer()
            Button(action: { deleteItem(item) }) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .accessibilityLabel("Delete \(item.name)") // VoiceOver reads "Delete Milk"
            Button(action: { toggleFavorite(item) }) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
            }
            .accessibilityLabel("Favorite \(item.name)")
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
