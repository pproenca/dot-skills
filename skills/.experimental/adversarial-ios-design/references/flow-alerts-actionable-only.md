---
title: Reserve alerts for actionable problems
tags: flow, alerts, feedback, interruption
---

## Reserve alerts for actionable problems

The wrong default is celebrating or narrating with alerts — "Saved!", "Copied to clipboard", a welcome message at launch. An alert is the system's highest-friction interruption: it blocks the whole screen and demands a tap to continue. The HIG draws the line at actionability: "People don't appreciate an interruption from an alert that's informative, but not actionable," and separately, "Avoid showing an alert when your app starts." Success and neutral status belong inline — a label change, a checkmark state, a transient banner — where they inform without demanding tribute.

**Evidence of violation:** an `.alert` whose only button is OK or a dismiss (no decision to make) and whose title or message reports success or neutral status — strings in the family of "Saved", "Done", "Copied", "Success", "Welcome"; or any alert triggered from the app root's or first screen's `onAppear`/`.task` at launch (what's-new notices, rating prompts, network-status banners). The reviewer cites the alert declaration and its trigger site. PASS: alerts that present an error or a decision requiring action; success conveyed inline in the view. N/A: no alerts in the target.

**Incorrect (a modal toll-booth after every successful save):**

```swift
import SwiftUI

struct EpisodeDetailView: View {
    let episode: Episode
    @State private var showSavedAlert = false

    var body: some View {
        ScrollView {
            EpisodeHeader(episode: episode)
            Button("Save for Later") {
                PlaylistStore.shared.save(episode)
                showSavedAlert = true
            }
        }
        // ⚠️ OK-only success alert — pure information, full-screen interruption
        .alert("Episode Saved!", isPresented: $showSavedAlert) {
            Button("OK") {}
        }
    }
}
```

**Correct (the control itself confirms, no interruption):**

```swift
import SwiftUI

struct EpisodeDetailView: View {
    let episode: Episode
    @State private var isSaved = false

    var body: some View {
        ScrollView {
            EpisodeHeader(episode: episode)
            Button(
                isSaved ? "Saved" : "Save for Later",
                systemImage: isSaved ? "checkmark" : "plus"
            ) {
                PlaylistStore.shared.save(episode)
                withAnimation { isSaved = true }
            }
            .disabled(isSaved)
        }
    }
}
```

Reference: [HIG — Alerts](https://developer.apple.com/design/human-interface-guidelines/alerts)
