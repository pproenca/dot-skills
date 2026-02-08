---
title: Support Drag and Drop for Content Transfer
impact: MEDIUM
impactDescription: enables intuitive content movement and sharing
tags: inter, drag-drop, transfer, content
---

## Support Drag and Drop for Content Transfer

Support drag and drop for moving and copying content. This is essential on iPad and useful on iPhone for reordering and cross-app sharing.

**Incorrect (no drag support for movable content):**

```swift
// List with reorder but no drag feedback
List {
    ForEach(items) { item in
        ItemRow(item: item)
    }
    .onMove { from, to in
        items.move(fromOffsets: from, toOffset: to)
    }
}
// Works in edit mode only, no direct drag

// Images without drag capability
Image("photo")
// Can't drag to share or save
```

**Correct (proper drag and drop support):**

```swift
// Reorderable list with drag
List {
    ForEach(items) { item in
        ItemRow(item: item)
            .draggable(item) // Enable drag
    }
    .onMove { from, to in
        items.move(fromOffsets: from, toOffset: to)
    }
}

// Drop target
DropZone()
    .dropDestination(for: Item.self) { items, location in
        handleDrop(items)
        return true
    }

// Draggable image
Image("photo")
    .draggable(Image("photo")) {
        // Custom drag preview
        Image("photo")
            .resizable()
            .frame(width: 100, height: 100)
            .opacity(0.8)
    }

// Transferable for custom types
struct Item: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .item)
    }
}

// Combined drag and drop for reorder
List {
    ForEach(items) { item in
        ItemRow(item: item)
    }
    .onMove { /* ... */ }
}
.environment(\.editMode, .constant(.active))
// Shows drag handles
```

**Drag and drop guidelines:**
- Show lift animation on drag start
- Provide clear drop targets with highlight
- Support both move and copy where appropriate
- Use spring animation for drops
- Cancel gracefully if dropped outside valid targets

Reference: [Drag and drop - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/drag-and-drop)
