---
title: Choose Sheet for Tasks, FullScreenCover for Immersion
impact: HIGH
impactDescription: wrong modal type causes 20-30% task abandonment — sheets that should be fullscreen lose context, and fullscreen modals that should be sheets trap the user
tags: taste, sheet, fullscreen, modal, kocienda-taste, edson-conviction
---

## Choose Sheet for Tasks, FullScreenCover for Immersion

Kocienda's taste distinguishes between a task (compose an email, edit a profile) and an immersive experience (play a video, onboard a new user). A sheet says "do this thing and return" — it preserves the context behind it, showing a peek of the parent screen. A fullScreenCover says "focus entirely on this" — it replaces the world. Edson's conviction demands choosing one paradigm and committing: a half-measure (fullscreen for a simple form) confuses the user about how to dismiss it.

**Incorrect (fullscreen for a simple task):**

```swift
struct ContactListView: View {
    @State private var isAddingContact = false

    var body: some View {
        List(contacts) { contact in
            ContactRow(contact: contact)
        }
        // Fullscreen for a simple form — overkill, loses context
        .fullScreenCover(isPresented: $isAddingContact) {
            AddContactView()
        }
    }
}
```

**Correct (sheet for task, fullscreen for immersion):**

```swift
struct ContactListView: View {
    @State private var isAddingContact = false
    @State private var selectedPhoto: Photo?

    var body: some View {
        List(contacts) { contact in
            ContactRow(contact: contact)
        }
        // Sheet: self-contained task with Cancel/Save
        .sheet(isPresented: $isAddingContact) {
            NavigationStack {
                AddContactForm()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { isAddingContact = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") { saveContact() }
                        }
                    }
            }
        }
        // FullScreenCover: immersive content requiring full attention
        .fullScreenCover(item: $selectedPhoto) { photo in
            PhotoViewer(photo: photo)
        }
    }
}
```

**Decision framework:**
| Scenario | Modal Type | Example |
|----------|-----------|---------|
| Create/edit something | `.sheet` | Compose email, edit profile |
| View details with back context | `.sheet` | Preview, quick look |
| Immersive media | `.fullScreenCover` | Video player, camera |
| Onboarding/setup flow | `.fullScreenCover` | Welcome flow, permissions |
| Multi-step wizard | `.fullScreenCover` | Checkout, registration |

**When NOT to use either:** For drill-down navigation (list → detail), use `NavigationLink` push instead of any modal. Modals are for branching tasks, not linear hierarchy.

Reference: [Modality - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/modality)
