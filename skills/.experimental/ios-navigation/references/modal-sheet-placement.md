---
title: Place .sheet on Container View, Not on NavigationLink
impact: HIGH
impactDescription: prevents dismiss bugs and duplicate presentations
tags: modal, sheet, placement, dismiss-bug
---

## Place .sheet on Container View, Not on NavigationLink

Placing .sheet on a NavigationLink or inside a ForEach row causes the sheet to be tied to that specific row's lifecycle. When the row is recycled during scrolling or the source view is removed, the sheet dismisses unexpectedly or presents duplicate sheets. Always attach .sheet to the outermost stable container like the List, VStack, or NavigationStack itself.

**Incorrect (sheet attached to each row inside ForEach):**

```swift
struct ContactsView: View {
    @State private var selectedContact: Contact?

    var body: some View {
        NavigationStack {
            List {
                ForEach(contacts) { contact in
                    Button(contact.name) {
                        selectedContact = contact
                    }
                    // BAD: Each row creates its own .sheet modifier.
                    // When SwiftUI recycles rows during scrolling, the sheet
                    // may dismiss unexpectedly. Multiple rows may also attempt
                    // to present simultaneously, causing a runtime warning:
                    // "Attempt to present ... which is already presenting"
                    .sheet(item: $selectedContact) { contact in
                        ContactDetailView(contact: contact)
                    }
                }
            }
        }
    }
}
```

**Correct (sheet attached to stable parent container):**

```swift
struct ContactsView: View {
    @State private var selectedContact: Contact?

    var body: some View {
        NavigationStack {
            List {
                ForEach(contacts) { contact in
                    Button(contact.name) {
                        selectedContact = contact
                    }
                }
            }
            .navigationTitle("Contacts")
            // GOOD: A single .sheet modifier on the List (or NavigationStack).
            // The sheet lifecycle is tied to the stable parent, not to any
            // individual row. No duplicate presentations, no dismiss-on-recycle.
            // The $selectedContact binding drives which contact is shown.
            .sheet(item: $selectedContact) { contact in
                ContactDetailView(contact: contact)
            }
        }
    }
}
```
