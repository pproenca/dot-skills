---
title: Place Actions in Toolbar with Correct Placement
impact: MEDIUM
impactDescription: positions actions where users expect them
tags: nav, toolbar, actions, buttons
---

## Place Actions in Toolbar with Correct Placement

Use toolbar modifiers with correct placements: primary actions on trailing edge, destructive/cancel on leading edge. Don't overcrowd the navigation bar.

**Incorrect (wrong placements or overcrowded):**

```swift
// Too many actions in navigation bar
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        HStack {
            Button("Edit") { }
            Button("Share") { }
            Button("Delete") { }
            Button("Archive") { }
        }
    }
}

// Primary action on wrong side
.toolbar {
    ToolbarItem(placement: .navigationBarLeading) {
        Button("Save") { } // Primary should be trailing
    }
}
```

**Correct (appropriate placement and count):**

```swift
// Standard edit screen
.toolbar {
    ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") { dismiss() }
    }
    ToolbarItem(placement: .confirmationAction) {
        Button("Save") { save() }
    }
}

// Detail screen with actions
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        Menu {
            Button("Share", systemImage: "square.and.arrow.up") { }
            Button("Duplicate", systemImage: "doc.on.doc") { }
            Divider()
            Button("Delete", systemImage: "trash", role: .destructive) { }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

// Bottom toolbar for bulk actions
.toolbar {
    ToolbarItemGroup(placement: .bottomBar) {
        Button("Select All") { }
        Spacer()
        Button("Delete", role: .destructive) { }
    }
}
```

**Toolbar placement semantics:**
| Placement | Position | Usage |
|-----------|----------|-------|
| `.cancellationAction` | Leading | Cancel, Close |
| `.confirmationAction` | Trailing | Save, Done |
| `.primaryAction` | Trailing | Main action |
| `.destructiveAction` | Trailing (red) | Delete |
| `.bottomBar` | Bottom | Bulk actions |

Reference: [Toolbars - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/toolbars)
