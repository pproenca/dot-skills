---
title: Protect unsaved sheet content before dismissal
tags: flow, sheets, data-loss, interactive-dismiss
---

## Protect unsaved sheet content before dismissal

The wrong default is an editable form in a sheet where drag-to-dismiss — or a bare Cancel button — silently destroys the user's draft. The HIG requires supporting swipe-to-dismiss on sheets, but with a guard: "If people have unsaved changes in the sheet when they begin swiping to dismiss it, use an action sheet to let them confirm their action." The mechanism is a dirty check: `.interactiveDismissDisabled(hasChanges)` blocks the accidental swipe once edits exist, and a `confirmationDialog` offers save/discard/keep-editing when dismissal is attempted. An editable sheet with zero protection is a data-loss bug wearing a design-pattern costume.

**Evidence of violation:** a `.sheet` containing user-editable input — `TextField`, `TextEditor`, or controls writing to draft state — with neither `.interactiveDismissDisabled(_:)` conditioned on a dirty check nor a dismiss-time `confirmationDialog` offering to save or discard; the absence of both mechanisms on an editable sheet is FAIL, not N/A. Also a violation: a Cancel button whose action discards a non-empty draft with no confirmation. PASS: `.interactiveDismissDisabled(hasUnsavedChanges)` (or an equivalent dirty predicate) paired with a `confirmationDialog` presenting options such as Save Draft / Discard Draft / Cancel — the reviewer cites both the modifier and the dialog. N/A: sheets with no editable input — read-only detail sheets, pickers where every selection commits immediately — the reviewer must cite the absence of draft state to claim this; absent that evidence, fail closed.

**Incorrect (one accidental swipe deletes a half-written trip note):**

```swift
import SwiftUI

struct TripNoteSheet: View {
    @Binding var trip: Trip
    @State private var noteText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            // ⚠️ Editable draft with no interactiveDismissDisabled and no discard confirmation
            TextEditor(text: $noteText)
                .navigationTitle("Trip Note")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            trip.notes.append(noteText)
                            dismiss()
                        }
                    }
                }
        }
    }
}
```

**Correct (dirty drafts block the swipe and confirm the discard):**

```swift
import SwiftUI

struct TripNoteSheet: View {
    @Binding var trip: Trip
    @State private var noteText = ""
    @State private var isConfirmingDiscard = false
    @Environment(\.dismiss) private var dismiss

    private var hasUnsavedChanges: Bool { !noteText.isEmpty }

    var body: some View {
        NavigationStack {
            TextEditor(text: $noteText)
                .navigationTitle("Trip Note")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            if hasUnsavedChanges {
                                isConfirmingDiscard = true
                            } else {
                                dismiss()
                            }
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            trip.notes.append(noteText)
                            dismiss()
                        }
                    }
                }
                .confirmationDialog(
                    "You have unsaved changes",
                    isPresented: $isConfirmingDiscard
                ) {
                    Button("Discard Note", role: .destructive) { dismiss() }
                    Button("Keep Editing", role: .cancel) {}
                }
        }
        .interactiveDismissDisabled(hasUnsavedChanges)
    }
}
```

Reference: [HIG — Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets), [interactiveDismissDisabled(_:)](https://developer.apple.com/documentation/swiftui/view/interactivedismissdisabled(_:))
