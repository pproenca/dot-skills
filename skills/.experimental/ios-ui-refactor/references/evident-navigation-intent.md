---
title: Sheets for Tasks and Creation, Push for Drill-Down Hierarchy
impact: HIGH
impactDescription: prevents 2-3 navigation dead-ends per flow — correct paradigm reduces "where am I?" confusion that causes 20-30% task abandonment
tags: evident, navigation, sheet, push, rams-4, segall-human, mental-model
---

## Sheets for Tasks and Creation, Push for Drill-Down Hierarchy

Rams demanded that products be self-explanatory — no manual required. When push navigation is used for a compose screen, the user must figure out that the back button means "cancel" and there's no "send." Segall's Think Human means using the navigation paradigm that matches the user's mental model: push means "go deeper," sheet means "do something and return."

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
