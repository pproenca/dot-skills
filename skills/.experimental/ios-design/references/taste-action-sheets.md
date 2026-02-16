---
title: Use Confirmation Dialogs for Contextual Multi-Choice Actions
impact: HIGH
impactDescription: confirmationDialog saves 50-80 lines vs custom alert buttons — handles 3-10 actions with O(1) built-in scrolling, destructive styling, and platform-adaptive presentation that takes 5× more code to reimplement
tags: taste, action-sheet, confirmation-dialog, kocienda-taste, edson-conviction, ux
---

## Use Confirmation Dialogs for Contextual Multi-Choice Actions

Kocienda's taste distinguishes between binary decisions (alert: "Delete? Yes/No") and contextual choices (confirmation dialog: "Share via AirDrop / Messages / Mail / Copy Link"). Alerts are for blocking yes/no decisions; confirmation dialogs present a scrollable list of actions that emerge from a specific context. Edson's conviction means using the right tool: cramming five options into an alert creates a confusing wall of buttons.

**Incorrect (alert with multiple action buttons):**

```swift
struct PhotoView: View {
    @State private var showOptions = false

    var body: some View {
        Image("photo")
            .onLongPressGesture { showOptions = true }
            // Alert with too many buttons — no visual hierarchy
            .alert("Photo Options", isPresented: $showOptions) {
                Button("Share") { share() }
                Button("Copy") { copy() }
                Button("Save to Album") { save() }
                Button("Edit") { edit() }
                Button("Delete", role: .destructive) { delete() }
                Button("Cancel", role: .cancel) { }
            }
    }
}
```

**Correct (confirmation dialog with grouped, labeled actions):**

```swift
struct PhotoView: View {
    @State private var showOptions = false

    var body: some View {
        Image("photo")
            .onLongPressGesture { showOptions = true }
            .confirmationDialog("Photo Options", isPresented: $showOptions) {
                Button("Share") { share() }
                Button("Copy") { copy() }
                Button("Save to Album") { save() }
                Button("Edit") { edit() }

                // Destructive action stands out with red styling
                Button("Delete Photo", role: .destructive) { delete() }
            } message: {
                Text("Choose an action for this photo.")
            }
    }
}
```

**Decision framework:**
| Scenario | Use | Why |
|----------|-----|-----|
| Yes/No decision | `.alert` | Binary, blocking |
| 3+ contextual actions | `.confirmationDialog` | Scrollable, hierarchical |
| Destructive confirmation | `.alert` | Forces explicit choice |
| Context menu (long press) | `.contextMenu` | Inline, non-modal |
| Actions on selected item | `.confirmationDialog` | Emerges from context |

**Presentation style differences:**
- iPhone: confirmation dialog slides up as a bottom sheet
- iPad: confirmation dialog appears as a popover from the source
- Use `.presentationDetents()` for custom sheet sizing if needed

**When NOT to use confirmation dialog:** For a single destructive action, use an alert with explicit "Cancel" / "Delete" buttons. Confirmation dialogs are for multiple options, not binary decisions.

Reference: [Action sheets - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/action-sheets)
