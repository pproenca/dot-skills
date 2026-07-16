---
title: Label alert buttons with specific verbs
tags: flow, alerts, copy, destructive
---

## Label alert buttons with specific verbs

The wrong default is a Yes/No alert — "Delete this entry?" with Yes and No buttons — which forces the user to re-read the title to know what Yes does, and an alert titled "Error" that says nothing at all. The HIG's grammar is concrete: "Prefer verbs and verb phrases," reserve "OK" for acceptance in purely informational alerts, avoid "Yes" and "No" entirely, and "Always use 'Cancel' to title a button that cancels the alert's action." Alerts hold at most three buttons, a destructive choice carries `role: .destructive`, and a destructive-consequence alert includes a Cancel escape. Titles convey the situation — never "Error" or a bare error code.

**Evidence of violation:** any of these shapes, each citable at the `.alert` declaration — a button titled "Yes" or "No"; more than three buttons in one alert; a destructive-consequence alert with no button titled exactly "Cancel"; a button performing a destructive action without `role: .destructive`; an alert title equal to "Error" or containing a bare error code; "OK" as the confirming choice of an alert that asks for a decision. PASS: one-or-two-word verb titles (Delete, Discard, Retry, View All), Cancel with `role: .cancel`, at most three buttons, roles set. N/A: no alerts in the target.

**Incorrect (Yes/No forces a re-read, and nothing marks the destruction):**

```swift
import SwiftUI

struct MeditationHistoryView: View {
    @State private var sessions: [MeditationSession] = []
    @State private var sessionToDelete: MeditationSession?

    var body: some View {
        List(sessions) { session in
            SessionRow(session: session)
                .onLongPressGesture { sessionToDelete = session }
        }
        // ⚠️ Yes/No labels, no destructive role, no Cancel
        .alert("Delete this session?", isPresented: .constant(sessionToDelete != nil)) {
            Button("Yes") {
                sessions.removeAll { $0.id == sessionToDelete?.id }
                sessionToDelete = nil
            }
            Button("No") { sessionToDelete = nil }
        }
    }
}
```

**Correct (the verb is the answer, the role marks the risk):**

```swift
import SwiftUI

struct MeditationHistoryView: View {
    @State private var sessions: [MeditationSession] = []
    @State private var sessionToDelete: MeditationSession?

    var body: some View {
        List(sessions) { session in
            SessionRow(session: session)
                .onLongPressGesture { sessionToDelete = session }
        }
        .alert(
            "Delete Session?",
            isPresented: .constant(sessionToDelete != nil),
            presenting: sessionToDelete
        ) { session in
            Button("Delete", role: .destructive) {
                sessions.removeAll { $0.id == session.id }
                sessionToDelete = nil
            }
            Button("Cancel", role: .cancel) { sessionToDelete = nil }
        } message: { session in
            Text("This removes \(session.title) from your history.")
        }
    }
}
```

Reference: [HIG — Alerts](https://developer.apple.com/design/human-interface-guidelines/alerts)
