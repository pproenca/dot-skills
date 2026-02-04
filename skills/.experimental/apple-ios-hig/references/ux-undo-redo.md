---
title: Support Undo for Destructive Actions
impact: MEDIUM
impactDescription: allows users to recover from mistakes
tags: ux, undo, redo, recovery
---

## Support Undo for Destructive Actions

Provide undo capability for destructive or significant actions. This gives users confidence to explore without fear of permanent mistakes.

**Incorrect (no recovery from mistakes):**

```swift
// Immediate permanent deletion
Button("Delete", role: .destructive) {
    permanentlyDelete(item) // No recovery
}

// Edit without undo
TextField("Bio", text: $bio)
    .onChange(of: bio) { newValue in
        // Auto-saves immediately, no undo
        save(bio: newValue)
    }
```

**Correct (undo support):**

```swift
// Soft delete with undo
Button("Delete", role: .destructive) {
    deletedItem = item
    withAnimation {
        items.removeAll { $0.id == item.id }
    }
    showUndoToast = true
}

// Undo toast
.safeAreaInset(edge: .bottom) {
    if showUndoToast {
        HStack {
            Text("Item deleted")
            Spacer()
            Button("Undo") {
                if let item = deletedItem {
                    items.append(item)
                    deletedItem = nil
                }
                showUndoToast = false
            }
        }
        .padding()
        .background(.regularMaterial)
        .transition(.move(edge: .bottom))
    }
}

// System undo manager integration
class Document: ObservableObject {
    let undoManager: UndoManager?

    func updateTitle(_ newTitle: String) {
        let oldTitle = title
        undoManager?.registerUndo(withTarget: self) { doc in
            doc.updateTitle(oldTitle)
        }
        undoManager?.setActionName("Update Title")
        title = newTitle
    }
}

// Shake to undo (system behavior)
// Enable by not disabling: .environment(\.undoManager, undoManager)

// Explicit undo/redo buttons for editors
.toolbar {
    ToolbarItemGroup(placement: .keyboard) {
        Button {
            undoManager?.undo()
        } label: {
            Image(systemName: "arrow.uturn.backward")
        }
        .disabled(!(undoManager?.canUndo ?? false))

        Button {
            undoManager?.redo()
        } label: {
            Image(systemName: "arrow.uturn.forward")
        }
        .disabled(!(undoManager?.canRedo ?? false))
    }
}
```

**Undo guidelines:**
- Always support undo for deletion
- Show brief toast with undo option
- Support shake-to-undo system gesture
- Implement UndoManager for complex edits
- Undo should restore exact previous state

Reference: [Undo and redo - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/undo-and-redo)
