---
title: Use Standard Gesture Patterns
impact: HIGH
impactDescription: non-standard gestures increase task completion time by 2-3× — users expect edge swipe for back, long press for context menu
tags: inter, gestures, swipe, tap, standard
---

## Use Standard Gesture Patterns

Use standard iOS gestures for their expected purposes. Don't override system gestures or create novel interactions where standards exist.

**Incorrect (non-standard gestures):**

```swift
// Overriding system edge swipe
.gesture(
    DragGesture()
        .onEnded { value in
            if value.startLocation.x < 50 {
                // Custom action instead of back navigation
                showMenu = true
            }
        }
)
// Conflicts with system back gesture

// Double-tap for action instead of zoom
Image("photo")
    .onTapGesture(count: 2) {
        likePhoto() // Users expect zoom
    }

// Horizontal swipe in a vertical list
List {
    ForEach(items) { item in
        ItemRow(item: item)
            .gesture(
                DragGesture()
                    .onEnded { _ in performAction() }
            )
    }
}
// Use swipeActions instead
```

**Correct (standard gesture usage):**

```swift
// Standard swipe actions on list rows
List {
    ForEach(items) { item in
        ItemRow(item: item)
            .swipeActions(edge: .trailing) {
                Button("Delete", role: .destructive) { delete(item) }
                Button("Archive") { archive(item) }
            }
            .swipeActions(edge: .leading) {
                Button("Pin") { pin(item) }
            }
    }
}

// Pull to refresh
List {
    // content
}
.refreshable {
    await loadData()
}

// Pinch to zoom on images (iOS 18+)
ScrollView {
    Image("photo")
        .resizable()
        .scaledToFit()
}
.defaultScrollAnchor(.center)

// Long press for context menu (system standard)
ItemRow(item: item)
    .contextMenu {
        Button("Share") { }
        Button("Edit") { }
    }
```

**Standard gesture expectations:**
| Gesture | Expected Action |
|---------|-----------------|
| Tap | Primary action |
| Double-tap | Zoom (images), like (social) |
| Long press | Context menu |
| Swipe left | Destructive actions |
| Swipe right | Positive actions |
| Pull down | Refresh, dismiss sheet |
| Edge swipe | Back navigation |
| Pinch | Zoom |

Reference: [Gestures - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/gestures)
