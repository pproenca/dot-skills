---
title: Use Menus for Secondary Actions
impact: MEDIUM
impactDescription: enables right-click/long-press menus with 2-8 contextual actions
tags: comp, menu, context-menu, overflow
---

## Use Menus for Secondary Actions

Use menus (via Menu or context menu) to group secondary actions. Primary actions should be immediately visible; menus are for less-frequent options.

**Incorrect (menu misuse):**

```swift
// Primary action hidden in menu
Menu {
    Button("Submit") { submit() } // This should be visible
    Button("Save Draft") { saveDraft() }
} label: {
    Text("Actions")
}

// No menu when needed - cluttered toolbar
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        HStack {
            Button("Edit") { }
            Button("Share") { }
            Button("Delete") { }
            Button("Archive") { }
        }
    }
}
```

**Correct (appropriate menu usage):**

```swift
// Overflow menu for secondary actions
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        Menu {
            Button("Share", systemImage: "square.and.arrow.up") {
                share()
            }
            Button("Duplicate", systemImage: "doc.on.doc") {
                duplicate()
            }
            Button("Edit", systemImage: "pencil") {
                edit()
            }
            Divider()
            Button("Delete", systemImage: "trash", role: .destructive) {
                delete()
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

// Context menu for item actions
ItemRow(item: item)
    .contextMenu {
        Button("Share", systemImage: "square.and.arrow.up") {
            share(item)
        }
        Button("Edit", systemImage: "pencil") {
            edit(item)
        }
        Divider()
        Button("Delete", systemImage: "trash", role: .destructive) {
            delete(item)
        }
    }

// Menu with picker
Menu {
    Picker("Sort By", selection: $sortOrder) {
        Label("Date", systemImage: "calendar").tag(SortOrder.date)
        Label("Name", systemImage: "textformat").tag(SortOrder.name)
        Label("Size", systemImage: "arrow.up.arrow.down").tag(SortOrder.size)
    }
} label: {
    Label("Sort", systemImage: "arrow.up.arrow.down")
}
```

**Menu guidelines:**
- Group related actions with Divider
- Use SF Symbols for discoverability
- Put destructive actions at end
- Keep menu items under ~7 options
- Use submenus sparingly (max 1 level)

Reference: [Menus - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/menus)
