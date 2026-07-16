---
title: Confirm intentional destructive actions with an anchored confirmation dialog
tags: flow, confirmation-dialog, destructive, action-sheet
---

## Confirm intentional destructive actions with an anchored confirmation dialog

The wrong default is confirming a user-initiated Delete with an `.alert`. Alerts are for unexpected interruptions; for choices that follow from an action the user just took, the HIG assigns the action sheet: "Use an action sheet — not an alert — to offer choices related to an intentional action." In SwiftUI that is `confirmationDialog`, and its attachment point matters: in regular width the system renders it as a popover anchored to its source, so a dialog attached to a distant container floats detached from the button that triggered it. The destructive option comes first, carries `role: .destructive`, and restates the consequence as a verb phrase ("Delete Album") so the confirmation reads without the title.

**Evidence of violation:** an `.alert` presenting the confirmation choices for an action the user just initiated (delete, discard, remove, irreversible sign-out); a `confirmationDialog` attached to a root or distant container rather than the triggering control or its immediate context; a destructive choice without `role: .destructive`; a destructive button whose title is a bare "Yes"/"OK" rather than a verb phrase naming the consequence. PASS: `.confirmationDialog` attached to (or presented from) the triggering element, destructive option first with the role and a consequence-naming title, Cancel present. N/A: no destructive confirmations in the target. Whether a confirmation is warranted at all is decided by the reversibility rule (`flow-no-confirm-undoable-deletes`), not here.

**Incorrect (an alert interrupts, unanchored, for a choice the user just asked for):**

```swift
import SwiftUI

struct AlbumDetailView: View {
    let album: PhotoAlbum
    @State private var isConfirmingDelete = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PhotoGrid(album: album)
            .toolbar {
                Button("Delete Album", systemImage: "trash") {
                    isConfirmingDelete = true
                }
            }
            // ⚠️ Alert used to confirm an intentional action — belongs in a confirmation dialog
            .alert("Are you sure?", isPresented: $isConfirmingDelete) {
                Button("OK") {
                    AlbumStore.shared.delete(album)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
    }
}
```

**Correct (the dialog anchors to the trash button and names the consequence):**

```swift
import SwiftUI

struct AlbumDetailView: View {
    let album: PhotoAlbum
    @State private var isConfirmingDelete = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PhotoGrid(album: album)
            .toolbar {
                Button("Delete Album", systemImage: "trash") {
                    isConfirmingDelete = true
                }
                .confirmationDialog(
                    "This album and its \(album.photoCount) photos will be deleted.",
                    isPresented: $isConfirmingDelete,
                    titleVisibility: .visible
                ) {
                    Button("Delete Album", role: .destructive) {
                        AlbumStore.shared.delete(album)
                        dismiss()
                    }
                }
            }
    }
}
```

Reference: [HIG — Action sheets](https://developer.apple.com/design/human-interface-guidelines/action-sheets), [confirmationDialog(_:isPresented:titleVisibility:actions:)](https://developer.apple.com/documentation/swiftui/view/confirmationdialog(_:ispresented:titlevisibility:actions:)-46zbb)
