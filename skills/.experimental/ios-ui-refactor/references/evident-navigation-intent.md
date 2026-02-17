---
title: Sheets for Tasks and Creation, Push for Drill-Down Hierarchy
impact: HIGH
impactDescription: prevents 2-3 navigation dead-ends per flow — correct paradigm eliminates the "where am I?" confusion that drives users to abandon tasks mid-flow
tags: evident, navigation, sheet, push, rams-4, segall-human, mental-model
---

## Sheets for Tasks and Creation, Push for Drill-Down Hierarchy

You tap "Compose" and the screen slides in from the right — the same animation as drilling into a message thread. For a split second, something feels wrong. Where's the Send button? The back arrow sits where Cancel should be, but does going back discard your draft or save it? That flicker of disorientation is the cost of mismatched navigation intent. Users carry a deep, learned vocabulary of motion: a push means "I'm going deeper into content," a sheet rising from below means "I'm doing a task and coming back." When the paradigm matches the mental model, navigation feels invisible. When it doesn't, every transition becomes a small riddle the user shouldn't have to solve.

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

**When NOT to apply:** Wizard-style multi-step creation flows where each step builds on the previous one -- push navigation through the steps preserves the back-trackable history that sheets would lose.

**Reference:** [Apple HIG — Modality](https://developer.apple.com/design/human-interface-guidelines/modality) — "Use a modal presentation only when it makes sense to require people to complete a task or dismiss a message before continuing."
