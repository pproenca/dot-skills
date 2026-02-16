---
title: Guard Unsaved Changes with interactiveDismissDisabled
impact: MEDIUM-HIGH
impactDescription: prevents data loss from accidental swipe-down
tags: modal, interactive-dismiss, data-loss, forms
---

## Guard Unsaved Changes with interactiveDismissDisabled

Sheets can be dismissed at any time with a swipe-down gesture. When the sheet contains a form with user input, an accidental swipe destroys all unsaved data with no confirmation. Use .interactiveDismissDisabled to lock the sheet while there are unsaved changes, and pair it with explicit Save and Cancel buttons so the user always has a deliberate path out. The sheet presentation itself must be coordinator-driven, but form-local input state (text fields, pickers) is legitimately view-owned since it represents transient UI input, not navigation state.

**Incorrect (form sheet that loses all input on accidental swipe):**

```swift
struct NewExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var category = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Amount", text: $amount)
                TextField("Category", text: $category)
                TextField("Notes", text: $notes)
            }
            .navigationTitle("New Expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAndDismiss() }
                }
            }
            // BAD: No protection against accidental swipe-down.
            // A user who has typed $47.50 into amount, selected "Dining",
            // and written detailed notes can lose everything with a
            // single inadvertent downward gesture. No confirmation dialog,
            // no recovery — the data is gone.
        }
    }
}
```

**Correct (coordinator-driven presentation with guarded dismiss and unsaved-changes tracking):**

```swift
enum SheetRoute: Identifiable {
    case newExpense

    var id: String {
        switch self {
        case .newExpense: "newExpense"
        }
    }
}

@Observable @MainActor
final class ExpenseCoordinator {
    var presentedSheet: SheetRoute?

    func presentNewExpense() {
        presentedSheet = .newExpense
    }

    func dismissSheet() {
        presentedSheet = nil
    }
}

@Equatable
struct NewExpenseView: View {
    @Environment(ExpenseCoordinator.self) private var coordinator
    // GOOD: Form input state (amount, category, notes) is legitimately
    // view-owned — it represents transient UI input, not navigation state.
    // The sheet presentation itself is coordinator-driven via presentedSheet.
    @State private var amount = ""
    @State private var category = ""
    @State private var notes = ""
    @State private var showDiscardAlert = false

    /// Track whether the user has entered any data worth protecting.
    private var hasUnsavedChanges: Bool {
        !amount.isEmpty || !category.isEmpty || !notes.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Amount", text: $amount)
                TextField("Category", text: $category)
                TextField("Notes", text: $notes)
            }
            .navigationTitle("New Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // GOOD: Explicit cancel with confirmation when there
                        // are unsaved changes. Clean dismiss when the form is empty.
                        // Dismissal goes through the coordinator so it remains
                        // the single source of truth for presentation state.
                        if hasUnsavedChanges {
                            showDiscardAlert = true
                        } else {
                            coordinator.dismissSheet()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAndDismiss() }
                        .disabled(amount.isEmpty)
                }
            }
            // GOOD: Locks swipe-to-dismiss only when there is data to lose.
            // When the form is empty, swipe-dismiss works normally so the
            // interaction doesn't feel unnecessarily heavy.
            .interactiveDismissDisabled(hasUnsavedChanges)
            .alert("Discard Changes?", isPresented: $showDiscardAlert) {
                Button("Discard", role: .destructive) { coordinator.dismissSheet() }
                Button("Keep Editing", role: .cancel) { }
            } message: {
                Text("You have unsaved changes that will be lost.")
            }
        }
    }
}
```
