---
title: Use Separate NavigationStack Inside Modals
impact: MEDIUM-HIGH
impactDescription: prevents modal navigation from corrupting parent stack
tags: modal, nested, navigation-stack, sheet
---

## Use Separate NavigationStack Inside Modals

Modals are not part of the parent NavigationStack. If you need drill-down navigation inside a sheet, you must embed a separate NavigationStack within it. Trying to use NavigationLink or navigationDestination inside a modal without its own stack will either silently fail or produce undefined behavior, because the modal has no reference to the parent's navigation context.

**Incorrect (NavigationLink inside a sheet with no NavigationStack):**

```swift
struct OrdersView: View {
    @State private var showSupport = false

    var body: some View {
        NavigationStack {
            OrderListView()
                .sheet(isPresented: $showSupport) {
                    // BAD: This sheet has no NavigationStack of its own.
                    // The NavigationLink inside SupportTopicsView will not work
                    // because the parent NavigationStack does not extend into
                    // the modal. Tapping a topic row does nothing, or in some
                    // iOS versions pushes onto the parent stack behind the sheet.
                    SupportTopicsView()
                }
        }
    }
}

struct SupportTopicsView: View {
    var body: some View {
        List(supportTopics) { topic in
            // This NavigationLink has no NavigationStack to push onto.
            NavigationLink(topic.title) {
                SupportDetailView(topic: topic)
            }
        }
        .navigationTitle("Support")
    }
}
```

**Correct (dedicated NavigationStack inside the modal):**

```swift
struct OrdersView: View {
    @State private var showSupport = false

    var body: some View {
        NavigationStack {
            OrderListView()
                .sheet(isPresented: $showSupport) {
                    // GOOD: The sheet has its own NavigationStack.
                    // Navigation inside the modal is fully independent of
                    // the parent stack. Pushing and popping views within
                    // this sheet does not affect OrdersView's navigation state.
                    NavigationStack {
                        SupportTopicsView()
                            .navigationDestination(for: SupportTopic.self) { topic in
                                SupportDetailView(topic: topic)
                            }
                    }
                }
        }
    }
}

struct SupportTopicsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(supportTopics) { topic in
            // GOOD: NavigationLink now pushes onto the modal's own stack.
            // Users get a back button and swipe-back gesture within the sheet.
            NavigationLink(value: topic) {
                Label(topic.title, systemImage: topic.icon)
            }
        }
        .navigationTitle("Support")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                // GOOD: Explicit close button to dismiss the entire modal.
                // The back button handles in-modal navigation; this handles
                // leaving the modal entirely.
                Button("Close") { dismiss() }
            }
        }
    }
}
```
