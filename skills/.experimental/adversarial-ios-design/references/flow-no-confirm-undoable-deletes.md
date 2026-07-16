---
title: Match confirmation friction to reversibility
tags: flow, confirmation, undo, destructive
---

## Match confirmation friction to reversibility

The wrong default applies confirmation uniformly: a prompt on every swipe-delete of a recoverable item, and — the mirror failure — a permanent purge that executes on a single tap. The HIG splits by reversibility: "Avoid displaying alerts for common, undoable actions, even when they're destructive," and conversely, "when people take an uncommon destructive action that they can't undo, it's important to display an alert in case they initiated the action accidentally." Confirmation prompts on routine undoable deletes train users to tap through them, which is exactly the reflex that later destroys the unrecoverable thing.

**Evidence of violation:** two legs, either one FAILs — (1) a confirmation prompt (alert or `confirmationDialog`) wrapping deletion of a routine item whose recovery path is citable in the same codebase: an `UndoManager` registration, a trash/Recently Deleted store, a soft-delete flag, or an undo banner; the reviewer must cite the recovery path to fire this leg. (2) an uncommon, irreversible destructive action — Empty Trash, Delete All Data, account deletion, permanent purge — executing with no confirmation; the absence of the confirmation is FAIL, not N/A. PASS: routine recoverable deletes execute immediately (`.onDelete`, swipe actions with `role: .destructive`); irreversible actions confirmed per `flow-confirmationdialog-destructive`. N/A: no destructive actions in the target.

**Incorrect (a prompt guards the recoverable delete, nothing guards the purge):**

```swift
import SwiftUI

struct DraftsListView: View {
    @State private var drafts: [MessageDraft] = []
    @State private var draftToDelete: MessageDraft?

    var body: some View {
        List {
            ForEach(drafts) { draft in
                DraftRow(draft: draft)
                    .swipeActions {
                        // ⚠️ Confirmation on a routine delete that Recently Deleted already protects
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            draftToDelete = draft
                        }
                    }
            }
        }
        .confirmationDialog("Delete draft?", isPresented: .constant(draftToDelete != nil)) {
            Button("Delete", role: .destructive) {
                DraftStore.shared.moveToRecentlyDeleted(draftToDelete!)
                draftToDelete = nil
            }
        }
        .toolbar {
            // ⚠️ Irreversible purge with no confirmation at all
            Button("Empty Recently Deleted") {
                DraftStore.shared.purgeRecentlyDeleted()
            }
        }
    }
}
```

**Correct (friction moved to where the loss is permanent):**

```swift
import SwiftUI

struct DraftsListView: View {
    @State private var drafts: [MessageDraft] = []
    @State private var isConfirmingPurge = false

    var body: some View {
        List {
            ForEach(drafts) { draft in
                DraftRow(draft: draft)
                    .swipeActions {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            DraftStore.shared.moveToRecentlyDeleted(draft)
                        }
                    }
            }
        }
        .toolbar {
            Button("Empty Recently Deleted") {
                isConfirmingPurge = true
            }
            .confirmationDialog(
                "Recently deleted drafts will be permanently removed.",
                isPresented: $isConfirmingPurge,
                titleVisibility: .visible
            ) {
                Button("Empty Recently Deleted", role: .destructive) {
                    DraftStore.shared.purgeRecentlyDeleted()
                }
            }
        }
    }
}
```

Reference: [HIG — Alerts](https://developer.apple.com/design/human-interface-guidelines/alerts)
