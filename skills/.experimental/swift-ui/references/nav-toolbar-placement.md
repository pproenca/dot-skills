---
title: Place Toolbar Items Correctly
impact: HIGH
impactDescription: follows iOS conventions for action placement
tags: nav, toolbar, navigation-bar, actions, placement
---

## Place Toolbar Items Correctly

iOS has conventions for toolbar button placement. Following them makes your app feel native and predictable.

**Incorrect (wrong placements):**

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
```

**Standard toolbar placements:**

```swift
// Leading (left side)
.cancellationAction    // Cancel, Close
.navigation            // Back, custom nav

// Trailing (right side)
.confirmationAction    // Done, Save, Add
.primaryAction         // Main action
.destructiveAction     // Delete (red)

// Bottom bar
.bottomBar             // Tab-like actions

// Keyboard
.keyboard              // Above keyboard

// Principal (center)
.principal             // Title area custom content
```

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
