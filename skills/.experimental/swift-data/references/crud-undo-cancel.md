---
title: Enable Undo and Use It to Cancel Edits
impact: MEDIUM-HIGH
impactDescription: enables cancel/undo flows for edits without manual state copying
tags: crud, undo, cancel, editing, state, data-layer
---

## Enable Undo and Use It to Cancel Edits

SwiftData can integrate with the system `UndoManager` so edits to persistent entities can be undone and redone using standard platform gestures. With undo enabled, you can implement a "Cancel" flow for *editing an existing entity* without copying every field into a separate draft state. This is a Data layer technique — it applies when editing `@Model` entities directly (e.g., in a detail view that wraps entity binding via the repository layer).

**Incorrect (manual draft state copy for editing):**

```swift
import SwiftUI
import SwiftData

struct TripEditView: View {
    @Bindable var trip: TripEntity

    @State private var draftName: String = ""
    @State private var draftStart: Date = .now
    @State private var draftEnd: Date = .now

    var body: some View {
        Form {
            TextField("Name", text: $draftName)
            DatePicker("Start", selection: $draftStart)
            DatePicker("End", selection: $draftEnd)
        }
        .onAppear {
            draftName = trip.name
            draftStart = trip.startDate
            draftEnd = trip.endDate
        }
        .toolbar {
            Button("Cancel") {
                // Easy to forget fields/relationships; lots of extra plumbing.
            }
            Button("Save") {
                trip.name = draftName
                trip.startDate = draftStart
                trip.endDate = draftEnd
            }
        }
    }
}
```

**Prerequisite:** Enable undo on the container: `.modelContainer(for: TripEntity.self, isUndoEnabled: true)`

**Correct (undo grouping for cancel-on-edit):**

```swift
struct TripEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.undoManager) private var undoManager
    @Bindable var trip: Trip
    @State private var didBeginUndoGroup = false

    var body: some View {
        Form {
            TextField("Name", text: $trip.name)
            DatePicker("Start", selection: $trip.startDate)
            DatePicker("End", selection: $trip.endDate)
        }
        .onAppear {
            undoManager?.removeAllActions()
            undoManager?.beginUndoGrouping()
            didBeginUndoGroup = true
        }
        .onDisappear {
            if didBeginUndoGroup {
                undoManager?.endUndoGrouping()
                didBeginUndoGroup = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    if didBeginUndoGroup {
                        undoManager?.endUndoGrouping()
                        didBeginUndoGroup = false
                    }
                    if undoManager?.canUndo == true {
                        undoManager?.undo()
                    }
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if didBeginUndoGroup {
                        undoManager?.endUndoGrouping()
                        didBeginUndoGroup = false
                    }
                    dismiss()
                }
            }
        }
    }
}
```

**When NOT to use:**
- You didn't enable undo on the model container (`isUndoEnabled: true`)
- You need a "draft review" flow with validation before touching the persistent model (use a separate draft type)

**Benefits:**
- System undo/redo gestures work automatically for model edits
- "Cancel" for editing existing models can revert without manual state-copy plumbing
- Keeps edit views small and focused (fewer extra `@State` properties)

Reference: [Dive deeper into SwiftData](https://developer.apple.com/videos/play/wwdc2023/10196/)

