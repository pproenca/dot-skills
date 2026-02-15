---
title: Handle context.save() Failures Instead of Ignoring Errors
impact: HIGH
impactDescription: prevents silent data loss when persistence writes fail
tags: crud, save, error, handling, model-context, data-integrity
---

## Handle context.save() Failures Instead of Ignoring Errors

`ModelContext.save()` can fail due to uniqueness constraint violations, validation errors, or underlying store issues. Using `try?` or ignoring the error means the user thinks their data was saved when it was not — leading to silent data loss. Always catch save errors, present them to the user, and either retry or roll back the operation.

**Incorrect (save error silently ignored — user thinks data was saved):**

```swift
struct TripEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var trip: Trip

    var body: some View {
        Form {
            TextField("Name", text: $trip.name)
            DatePicker("Start", selection: $trip.startDate)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    try? context.save() // Failure is silently swallowed
                    dismiss() // User thinks trip was saved — it was not
                }
            }
        }
    }
}
```

**Correct (catch error and present it to the user):**

```swift
struct TripEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var trip: Trip
    @State private var saveError: Error?

    var body: some View {
        Form {
            TextField("Name", text: $trip.name)
            DatePicker("Start", selection: $trip.startDate)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    do {
                        try context.save()
                        dismiss()
                    } catch {
                        saveError = error
                    }
                }
            }
        }
        .alert(
            "Unable to Save",
            isPresented: Binding(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )
        ) {
            Button("Retry") {
                do {
                    try context.save()
                    dismiss()
                } catch {
                    saveError = error
                }
            }
            Button("Discard Changes", role: .destructive) {
                context.rollback()
                dismiss()
            }
        } message: {
            Text(saveError?.localizedDescription ?? "An unknown error occurred.")
        }
    }
}
```

**When NOT to use:**
- Preview and test code where save failures should crash immediately to surface bugs
- Autosave-only flows where the system handles persistence — but still log errors for diagnostics

**Benefits:**
- User always knows whether their data was persisted
- Retry option recovers from transient failures
- Rollback option prevents the context from accumulating invalid state
- `localizedDescription` gives actionable feedback for constraint violations

Reference: [SwiftData — Saving Models with ModelContext — Medium](https://medium.com/@nicrofilm/swiftdata-saving-models-with-modelcontext-747e29605980)
