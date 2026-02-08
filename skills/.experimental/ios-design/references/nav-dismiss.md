---
title: Use Environment Dismiss for Modal Closure
impact: HIGH
impactDescription: clean dismissal without passing closures through hierarchy
tags: nav, dismiss, environment, modal, sheet
---

## Use Environment Dismiss for Modal Closure

The `@Environment(\.dismiss)` action provides a clean way to close modals without passing callbacks through the view hierarchy.

**Incorrect (passing dismiss callback):**

```swift
struct ParentView: View {
    @State private var showingEditor = false

    var body: some View {
        Button("Edit") { showingEditor = true }
            .sheet(isPresented: $showingEditor) {
                EditorView(onDismiss: { showingEditor = false })
            }
    }
}

struct EditorView: View {
    let onDismiss: () -> Void  // Callback passed through

    var body: some View {
        NavigationStack {
            Form { /* ... */ }
                .toolbar {
                    Button("Done") { onDismiss() }
                }
        }
    }
}
```

**Correct (environment dismiss):**

```swift
struct ParentView: View {
    @State private var showingEditor = false

    var body: some View {
        Button("Edit") { showingEditor = true }
            .sheet(isPresented: $showingEditor) {
                EditorView()
            }
    }
}

struct EditorView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form { /* ... */ }
                .toolbar {
                    Button("Done") { dismiss() }
                }
        }
    }
}
```

**Works in nested views too:**

```swift
struct DeepNestedView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button("Close Modal") {
            dismiss()  // Dismisses the entire modal, not just this view
        }
    }
}
```

**Dismiss with confirmation:**

```swift
struct UnsavedChangesEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var hasChanges = false
    @State private var showingConfirmation = false

    var body: some View {
        Form { /* ... */ }
            .toolbar {
                Button("Cancel") {
                    if hasChanges {
                        showingConfirmation = true
                    } else {
                        dismiss()
                    }
                }
            }
            .confirmationDialog("Discard changes?", isPresented: $showingConfirmation) {
                Button("Discard", role: .destructive) { dismiss() }
                Button("Keep Editing", role: .cancel) { }
            }
    }
}
```

Reference: [DismissAction Documentation](https://developer.apple.com/documentation/swiftui/dismissaction)
