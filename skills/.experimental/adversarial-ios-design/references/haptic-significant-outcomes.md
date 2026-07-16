---
title: Pair significant outcome UI with notification haptics
tags: haptic, sensoryfeedback, success, error
---

## Pair significant outcome UI with notification haptics

The wrong default is an app with zero haptics anywhere: it renders a checkmark for a completed payment or an alert for a failed upload, but is silent to the hand holding the device. Apple's notification haptics exist precisely for task outcomes — success indicates a task or action has completed, error indicates an error has occurred — and feedback delivered through multiple channels reaches people who have silenced their device, looked away, or use VoiceOver. The app has already decided which outcomes matter by designing UI for them; the haptic belongs on the same state change.

**Evidence of violation:** a flow that renders designed outcome UI — a success checkmark, confirmation toast or banner, or a failure alert — for a significant task (payment, publish, upload, submission, a delete with consequences), with no `.sensoryFeedback(.success, trigger:)` / `.sensoryFeedback(.error, trigger:)` (or `UINotificationFeedbackGenerator` call) bound to the same state change that drives the visual. The presence of designed outcome UI is the citable predicate for "significant" — cite the outcome view and the absence of a feedback modifier keyed to its state; the absence is the violation, so an outcome flow with no haptic surface anywhere is FAIL, not N/A. Outcome UI that itself violates another rule still counts as the predicate — an OK-only "Saved!" alert is simultaneously a `flow-alerts-actionable-only` violation and evidence of a haptic-less outcome here; each rule judges its own axis, and one violation never exempts another. PASS: `.sensoryFeedback(.success/.error, trigger:)` on the flow's view, keyed to the same state that drives the visual confirmation — cite the modifier and its trigger. N/A: the target contains no flow that renders designed outcome UI for a task.

**Incorrect (the transfer confirmation is visual-only — silent to touch):**

```swift
import SwiftUI

struct TransferConfirmationView: View {
    @State private var transferSucceeded = false

    var body: some View {
        VStack(spacing: 16) {
            if transferSucceeded {
                // ⚠️ Designed success UI with no matching notification haptic
                Label("Transfer Sent", systemImage: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
            Button("Send $250 to Amara") {
                Task {
                    try await Task.sleep(for: .seconds(1))
                    transferSucceeded = true
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
```

**Correct (the success haptic fires on the same state change as the checkmark):**

```swift
import SwiftUI

struct TransferConfirmationView: View {
    @State private var transferSucceeded = false

    var body: some View {
        VStack(spacing: 16) {
            if transferSucceeded {
                Label("Transfer Sent", systemImage: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
            Button("Send $250 to Amara") {
                Task {
                    try await Task.sleep(for: .seconds(1))
                    transferSucceeded = true
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .sensoryFeedback(.success, trigger: transferSucceeded) { _, newValue in
            newValue
        }
    }
}
```

Reference: [Human Interface Guidelines — Playing haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics), [Human Interface Guidelines — Feedback](https://developer.apple.com/design/human-interface-guidelines/feedback), [sensoryFeedback](https://developer.apple.com/documentation/swiftui/sensoryfeedback)
