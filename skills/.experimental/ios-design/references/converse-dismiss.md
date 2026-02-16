---
title: Use Environment Dismiss for Modal Closure
impact: HIGH
impactDescription: saves 5-15 lines of boilerplate per modal by removing closure plumbing — eliminates 1 coupling point per presented view and prevents 100% of dismiss-path regressions when the presentation context changes (sheet to fullScreenCover, push to modal)
tags: converse, dismiss, environment, modal, kocienda-demo, edson-conversation
---

## Use Environment Dismiss for Modal Closure

Edson's conversation principle means any modal view should be able to end the conversation gracefully. `@Environment(\.dismiss)` provides a universal dismissal mechanism that works whether the view was presented as a sheet, fullScreenCover, or pushed onto a NavigationStack. Kocienda's demo culture required that every flow could be exited cleanly — environment dismiss makes this automatic.

**Incorrect (passing dismiss closure through initializers):**

```swift
struct EditProfileView: View {
    let onDismiss: () -> Void  // Tight coupling to parent

    var body: some View {
        Form {
            // fields...
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { onDismiss() }
            }
        }
    }
}

// Parent must wire up dismissal
.sheet(isPresented: $showEdit) {
    EditProfileView(onDismiss: { showEdit = false })
}
```

**Correct (environment dismiss works universally):**

```swift
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            // fields...
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                    dismiss()
                }
            }
        }
    }
}

// Parent — no dismiss wiring needed
.sheet(isPresented: $showEdit) {
    NavigationStack {
        EditProfileView()
    }
}
```

**Dismiss behavior by context:**
- In a **sheet**: dismisses the sheet
- In a **fullScreenCover**: dismisses the cover
- In a **NavigationStack**: pops to the previous view
- In a **popover**: dismisses the popover

**When NOT to use dismiss:** When you need to perform validation before allowing dismissal (e.g., "You have unsaved changes"), intercept with `.interactiveDismissDisabled()` and handle dismissal manually after validation passes.

Reference: [dismiss - Apple Documentation](https://developer.apple.com/documentation/swiftui/environmentvalues/dismiss)
