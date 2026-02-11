---
title: Sheets for Tasks and Creation, Push for Drill-Down Hierarchy
impact: HIGH
impactDescription: Mismatched navigation paradigm confuses the user's mental model — using push for creation flows hides the originating context, while sheets for browsing detail breaks hierarchical wayfinding
tags: trans, sheet, push, navigation, modality, mental-model
---

## Sheets for Tasks and Creation, Push for Drill-Down Hierarchy

Push navigation means "go deeper into this content." Sheets mean "do something, then return." When an app uses push to present a compose screen, the user loses sight of the list they were in and has no visual cue that they are in a temporary task. When an app uses a sheet to show browsing detail, the user cannot swipe back through a hierarchy and feels trapped. Apple Mail uses a sheet for compose and push for message detail — this is not a coincidence.

**Incorrect (push navigation for a creation/task flow):**

```swift
struct InboxView: View {
    var body: some View {
        NavigationStack {
            List(messages) { message in
                NavigationLink(value: message) {
                    MessageRow(message: message)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    // Pushing a compose screen buries it in the nav stack —
                    // user sees a back arrow instead of Cancel/Send
                    NavigationLink("Compose") {
                        ComposeMessageView()
                    }
                }
            }
            .navigationDestination(for: Message.self) { message in
                MessageDetailView(message: message)
            }
        }
    }
}
```

**Correct (sheet for compose, push for detail):**

```swift
struct InboxView: View {
    @State private var isComposing = false

    var body: some View {
        NavigationStack {
            List(messages) { message in
                // Push: drill into existing content hierarchy
                NavigationLink(value: message) {
                    MessageRow(message: message)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Compose", systemImage: "square.and.pencil") {
                        isComposing = true
                    }
                }
            }
            .navigationDestination(for: Message.self) { message in
                MessageDetailView(message: message)
            }
            // Sheet: self-contained task with its own Cancel/Send toolbar
            .sheet(isPresented: $isComposing) {
                NavigationStack {
                    ComposeMessageView()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { isComposing = false }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Send") { sendMessage() }
                            }
                        }
                }
            }
        }
    }
}
```

**Decision framework:**
| Scenario | Pattern | Example |
|---|---|---|
| Browse deeper into content | `NavigationLink` (push) | Message → thread → attachment |
| Create, edit, or complete a task | `.sheet` | Compose email, add contact, edit profile |
| Immersive content requiring full attention | `.fullScreenCover` | Video playback, onboarding, camera |
| Quick reference without leaving context | `.popover` on iPad, `.sheet` on iPhone | Date picker, font selector |

**Reference:** [Apple HIG — Modality](https://developer.apple.com/design/human-interface-guidelines/modality) — "Use a modal presentation only when it makes sense to require people to complete a task or dismiss a message before continuing."
