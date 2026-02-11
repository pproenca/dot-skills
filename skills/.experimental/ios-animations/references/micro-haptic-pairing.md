---
title: Pair Every Visual State Change with Haptic Feedback
impact: HIGH
impactDescription: haptics make interactions feel physical — visual-only feedback feels like touching glass
tags: micro, haptic, sensoryFeedback, pairing, feedback
---

## Pair Every Visual State Change with Haptic Feedback

Every meaningful state change deserves a haptic. When a toggle flips, a button confirms, or a deletion completes, the user's finger is already on the screen — a haptic tap at that exact moment makes the UI feel like a physical mechanism instead of pixels behind glass. iOS 17 introduced `.sensoryFeedback`, which is the declarative SwiftUI way to trigger haptics in response to state changes. It ties directly to a value's change, ensuring the haptic fires at the same frame as the visual transition.

**Incorrect (toggle animates but produces no haptic — feels hollow):**

```swift
struct AirplaneModeToggle: View {
    @State private var isEnabled = false

    var body: some View {
        HStack {
            Label("Airplane Mode", systemImage: "airplane")
            Spacer()

            // Custom toggle indicator
            Capsule()
                .fill(isEnabled ? Color.orange : Color(.systemGray4))
                .frame(width: 51, height: 31)
                .overlay(alignment: isEnabled ? .trailing : .leading) {
                    Circle()
                        .fill(.white)
                        .padding(2)
                        .frame(width: 27, height: 27)
                }
                .animation(.snappy, value: isEnabled)
                .onTapGesture {
                    isEnabled.toggle()
                }
        }
        .padding()
        // No haptic at all — the toggle slides silently. The user sees
        // it move but feels nothing under their finger. The interaction
        // feels disconnected and uncertain.
    }
}
```

**Correct (sensoryFeedback fires in sync with the visual change):**

```swift
struct AirplaneModeToggle: View {
    @State private var isEnabled = false

    var body: some View {
        HStack {
            Label("Airplane Mode", systemImage: "airplane")
            Spacer()

            Capsule()
                .fill(isEnabled ? Color.orange : Color(.systemGray4))
                .frame(width: 51, height: 31)
                .overlay(alignment: isEnabled ? .trailing : .leading) {
                    Circle()
                        .fill(.white)
                        .padding(2)
                        .frame(width: 27, height: 27)
                }
                .animation(.snappy, value: isEnabled)
                .onTapGesture {
                    isEnabled.toggle()
                }
        }
        .padding()
        // .selection is the right haptic for a binary toggle — a soft
        // "tick" that confirms the state locked in
        .sensoryFeedback(.selection, trigger: isEnabled)
    }
}
```

**Haptic type reference — which feedback for which interaction:**

| Interaction | Haptic Type | Feels like |
|---|---|---|
| Toggle / switch / selection change | `.selection` | Soft tick, like a detent |
| Button tap confirmation | `.impact(.light)` | Light tap |
| Destructive action (delete, remove) | `.impact(.medium)` | Firm knock |
| Success (task complete, saved) | `.success` | Double-tap "done" |
| Error (validation failed) | `.error` | Three rapid buzzes |
| Warning (approaching limit) | `.warning` | Two firm taps |
| Drag snap to position | `.impact(.rigid)` | Crisp snap |
| Pull-to-refresh trigger | `.impact(.light)` | Subtle bump at threshold |

**Multiple haptics in a complex flow:**

```swift
struct TaskRow: View {
    @State private var isComplete = false
    @State private var showDelete = false

    var body: some View {
        HStack(spacing: 12) {
            Button {
                isComplete.toggle()
            } label: {
                Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isComplete ? .green : .secondary)
            }
            .buttonStyle(.plain)

            Text("Buy groceries")
                .strikethrough(isComplete)
                .foregroundStyle(isComplete ? .secondary : .primary)

            Spacer()

            Button(role: .destructive) {
                showDelete = true
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
        // Each state change gets its own semantically correct haptic
        .sensoryFeedback(.success, trigger: isComplete) { oldValue, newValue in
            newValue == true
        }
        .sensoryFeedback(.selection, trigger: isComplete) { oldValue, newValue in
            newValue == false
        }
        .sensoryFeedback(.impact(.medium), trigger: showDelete)
    }
}
```

**Key rules for haptic pairing:**
- Never fire a haptic without a corresponding visual change — phantom haptics confuse users
- Never skip a haptic on a visible state change — the absence is noticeable after experiencing it once
- Match haptic intensity to action significance: light for routine, medium for important, heavy for destructive
- `.sensoryFeedback` respects the system Silent Mode switch automatically — no manual checks needed

Reference: [WWDC 2023 — What's new in SwiftUI](https://developer.apple.com/wwdc23/10148), Apple Human Interface Guidelines — Playing haptics
