---
title: Enable Undo and Use It to Cancel Edits
impact: MEDIUM-HIGH
impactDescription: enables cancel/undo flows for edits without manual state copying
tags: crud, undo, cancel, editing, state
---

## Enable Undo and Use It to Cancel Edits

SwiftData can integrate with the system `UndoManager` so edits to persistent models can be undone and redone using standard platform gestures. With undo enabled, you can also implement a "Cancel" flow for *editing an existing model* without copying every field into a separate draft state.

**Incorrect (manual draft state copy for editing):**

```swift
import SwiftUI
import SwiftData

struct TripEditView: View {
    @Bindable var trip: Trip

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

**Correct (enable undo and use it to cancel an edit session):**

```swift
import SwiftUI
import SwiftData

@main
struct TripsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Trip.self, isUndoEnabled: true)
    }
}

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
            // Scope undo to this sheet to avoid undoing unrelated actions.
            undoManager?.removeAllActions()

            undoManager?.beginUndoGrouping()
            undoManager?.setActionName("Edit Trip")
            didBeginUndoGroup = true
        }
        .onDisappear {
            // Avoid leaking a grouping level if the sheet is dismissed interactively.
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
                        undoManager?.undo() // Revert the whole edit session.
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

