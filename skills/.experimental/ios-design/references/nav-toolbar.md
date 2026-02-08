---
title: Place Toolbar Items Correctly
impact: HIGH
impactDescription: follows iOS conventions for action placement and avoids overcrowding
tags: nav, toolbar, navigation-bar, actions, placement
---

## Place Toolbar Items Correctly

iOS has conventions for toolbar button placement. Following them makes your app feel native and predictable. Don't overcrowd the navigation bar -- use menus for secondary actions.

**Incorrect (wrong placements or overcrowded):**

```swift
struct NoteEditor: View {
    var body: some View {
        TextEditor(text: $note.content)
            .toolbar {
                Button("Cancel") { dismiss() }  // No placement
                Button("Save") { save() }       // Default placement
            }
    }
}

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
```

**Correct (proper placements):**

```swift
struct NoteEditor: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TextEditor(text: $note.content)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
    }
}

// Detail screen with overflow menu
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
```

**Standard toolbar placements:**

| Placement | Position | Usage |
|-----------|----------|-------|
| `.cancellationAction` | Leading | Cancel, Close |
| `.confirmationAction` | Trailing | Save, Done |
| `.primaryAction` | Trailing | Main action |
| `.destructiveAction` | Trailing (red) | Delete |
| `.navigation` | Leading | Back, custom nav |
| `.principal` | Center | Title area custom content |
| `.bottomBar` | Bottom | Bulk actions |
| `.keyboard` | Above keyboard | Input accessories |

**Complete toolbar example:**

```swift
struct DocumentEditor: View {
    var body: some View {
        EditorContent()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(document.title).font(.headline)
                        Text("Edited 2m ago").font(.caption)
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { save() }
                        .fontWeight(.semibold)
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    Button { } label: { Image(systemName: "bold") }
                    Button { } label: { Image(systemName: "italic") }
                    Spacer()
                    Button { } label: { Image(systemName: "photo") }
                }
            }
    }
}
```

Reference: [Human Interface Guidelines - Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars)
