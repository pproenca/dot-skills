---
title: Choose Button vs Toggle by Interaction Type
impact: HIGH
impactDescription: prevents user confusion from wrong control type
tags: comp, button, toggle, switch, control
---

## Choose Button vs Toggle by Interaction Type

Buttons trigger actions. Toggles change state. Users have strong expectations about how each behaves.

**Incorrect (Button for on/off state):**

```swift
struct AudioControls: View {
    @State private var isMuted = false

    var body: some View {
        Button(isMuted ? "Unmute" : "Mute") {
            isMuted.toggle()
        }
        // Label changes, confusing which state is active
        // Doesn't communicate current state clearly
    }
}
```

**Correct (Toggle for binary state):**

```swift
struct AudioControls: View {
    @State private var isMuted = false

    var body: some View {
        Toggle("Mute", isOn: $isMuted)
        // Clear on/off state visible at all times
        // Matches user expectation for settings
    }
}
```

**Use Button for actions:**

```swift
struct SubscriptionView: View {
    var body: some View {
        VStack(spacing: 16) {
            Button("Subscribe Now") { subscribe() }
                .buttonStyle(.borderedProminent)

            Button("Cancel Subscription", role: .destructive) {
                showCancelConfirmation = true
            }
        }
    }
}
```

**Use Toggle for persistent settings:**

```swift
struct NotificationSettings: View {
    @AppStorage("pushEnabled") private var pushEnabled = true
    @AppStorage("soundEnabled") private var soundEnabled = true

    var body: some View {
        Form {
            Toggle("Push Notifications", isOn: $pushEnabled)
            Toggle("Sound Effects", isOn: $soundEnabled)
        }
    }
}
```

**Decision matrix:**

| Interaction | Control |
|-------------|---------|
| Submit form | Button |
| Delete item | Button |
| Enable/disable feature | Toggle |
| On/off setting | Toggle |

Reference: [Human Interface Guidelines - Toggles](https://developer.apple.com/design/human-interface-guidelines/toggles)
