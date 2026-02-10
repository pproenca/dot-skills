---
title: Use Haptic Feedback for Meaningful Events
impact: MEDIUM-HIGH
impactDescription: appropriate haptics reduce perceived latency by 50-100ms and increase user confidence in completed actions
tags: inter, haptics, feedback, taptic, interaction, touch
---

## Use Haptic Feedback for Meaningful Events

Use haptic feedback to confirm actions and provide tactile responses. Match haptic intensity to action importance. Don't overuse haptics or they lose meaning.

**Incorrect (misused or excessive haptics):**

```swift
// Haptic on every scroll
ScrollView {
    ForEach(items) { item in
        ItemRow(item: item)
            .onAppear {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
    }
}
// Overwhelming and meaningless

// Wrong haptic for action
Button("Delete") {
    UINotificationFeedbackGenerator().notificationOccurred(.success)
    // Success haptic for destructive action feels wrong
}

// No tactile feedback at all
struct RatingView: View {
    @State private var rating = 0

    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .onTapGesture {
                        rating = star  // Silent, no feedback
                    }
            }
        }
    }
}
```

**Correct (meaningful haptic feedback):**

```swift
// SwiftUI sensoryFeedback (iOS 17+)
Button("Add to Cart") {
    addToCart()
}
.sensoryFeedback(.success, trigger: addedToCart)

// Toggle with haptic
Toggle("Enable Notifications", isOn: $notificationsEnabled)
    .sensoryFeedback(.selection, trigger: notificationsEnabled)

// Rating with haptic on selection
struct RatingView: View {
    @State private var rating = 0

    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundStyle(star <= rating ? .yellow : .gray)
                    .onTapGesture {
                        rating = star
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
            }
        }
    }
}
```

**Haptic types:**

```swift
// Impact - physical collision feel
UIImpactFeedbackGenerator(style: .light).impactOccurred()   // Subtle tap
UIImpactFeedbackGenerator(style: .medium).impactOccurred()  // Button press
UIImpactFeedbackGenerator(style: .heavy).impactOccurred()   // Strong impact

// Selection - scrolling through options
UISelectionFeedbackGenerator().selectionChanged()

// Notification - success/warning/error
UINotificationFeedbackGenerator().notificationOccurred(.success)
UINotificationFeedbackGenerator().notificationOccurred(.warning)
UINotificationFeedbackGenerator().notificationOccurred(.error)
```

**UIKit haptics with lower latency:**

```swift
struct HapticButton: View {
    let action: () -> Void
    // Prepare before the expected event for lower latency
    let generator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        Button("Submit") {
            action()
            generator.impactOccurred()
        }
        .onAppear { generator.prepare() } // warm up engine ahead of time
    }
}
```

**UIKit HapticManager for reuse:**

```swift
struct HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}

// Success completion
HapticManager.notification(.success)

// Error or failure
HapticManager.notification(.error)

// Selection changed
HapticManager.impact(.light)

// Button press
HapticManager.impact(.medium)

// Significant action
HapticManager.impact(.heavy)
```

**Haptic type guidelines:**
| Haptic | Usage |
|--------|-------|
| `.selection` | Picker changes, toggles |
| `.success` | Task completed, saved |
| `.warning` | Approaching limit |
| `.error` | Failed action |
| `.light` | Subtle feedback, toggle/switch changes |
| `.medium` | Standard button, pull to refresh trigger |
| `.heavy` | Significant action |

**When to use haptics:**
- Toggle/switch changes: .light impact
- Button confirmations: .medium impact
- Destructive actions: .warning notification
- Success states: .success notification
- Picker selection: .selectionChanged
- Pull to refresh trigger: .medium impact

Reference: [Playing haptics - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)
