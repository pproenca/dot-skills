---
title: Present commit-ending tasks as sheets, not navigation pushes
tags: flow, modality, sheets, navigation
---

## Present commit-ending tasks as sheets, not navigation pushes

The wrong default for a compose, create, edit, or filter screen is a `NavigationLink` push onto the main stack. A pushed form has only the system Back button as an exit, so there is no commit-or-cancel grammar: tapping Back neither saves nor asks, it just walks away from the work. Modality exists precisely for this shape of task — the HIG frames a sheet as the tool for "a simple task that they can complete before returning to the parent view." The decidable predicate is the commit control: a screen that ends in an explicit Save, Done, Send, or Add action is a self-contained task, and a self-contained task is presented as a sheet with its own navigation bar and explicit dismiss affordances.

**Evidence of violation:** a screen whose toolbar or body ends in an explicit commit action — a button titled Save, Done, Send, Add, or Create, a `.confirmationAction` toolbar item, or an equivalent submit handler — reached via `NavigationLink` or `navigationDestination` on the main stack, with the system Back button as its only exit. PASS: the same screen presented via `.sheet` (or `.fullScreenCover` where its media/multistep enumeration applies), wrapped in its own `NavigationStack` with a title and Cancel/Done toolbar items — the reviewer cites the presentation site. N/A: destinations with no commit affordance — pure content drill-downs, detail views, browsing hierarchies — the reviewer must cite the absence of a commit control to claim this; absent that evidence, fail closed. N/A: no navigation or presentation in the target.

**Incorrect (Back silently walks away from a half-written expense):**

```swift
import SwiftUI

struct ExpenseListView: View {
    @State private var expenses: [Expense] = []

    var body: some View {
        NavigationStack {
            List(expenses) { expense in
                ExpenseRow(expense: expense)
            }
            .navigationTitle("Expenses")
            .toolbar {
                // ⚠️ A commit-ending form pushed onto the stack — Back discards silently
                NavigationLink("New Expense") {
                    NewExpenseForm(expenses: $expenses)
                }
            }
        }
    }
}

struct NewExpenseForm: View {
    @Binding var expenses: [Expense]
    @State private var draft = Expense()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            TextField("Merchant", text: $draft.merchant)
            TextField("Amount", value: $draft.amount, format: .currency(code: "EUR"))
        }
        .navigationTitle("New Expense")
        .toolbar {
            Button("Save") {
                expenses.append(draft)
                dismiss()
            }
        }
    }
}
```

**Correct (the sheet carries commit-or-cancel grammar):**

```swift
import SwiftUI

struct ExpenseListView: View {
    @State private var expenses: [Expense] = []
    @State private var isAddingExpense = false

    var body: some View {
        NavigationStack {
            List(expenses) { expense in
                ExpenseRow(expense: expense)
            }
            .navigationTitle("Expenses")
            .toolbar {
                Button("New Expense", systemImage: "plus") {
                    isAddingExpense = true
                }
            }
            .sheet(isPresented: $isAddingExpense) {
                NewExpenseForm(expenses: $expenses)
            }
        }
    }
}

struct NewExpenseForm: View {
    @Binding var expenses: [Expense]
    @State private var draft = Expense()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Merchant", text: $draft.merchant)
                TextField("Amount", value: $draft.amount, format: .currency(code: "EUR"))
            }
            .navigationTitle("New Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        expenses.append(draft)
                        dismiss()
                    }
                }
            }
        }
    }
}
```

Reference: [HIG — Modality](https://developer.apple.com/design/human-interface-guidelines/modality), [HIG — Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)
