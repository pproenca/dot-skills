---
title: Use Haptic Feedback for Meaningful Events
impact: MEDIUM-HIGH
impactDescription: provides tactile confirmation that enhances user experience
tags: inter, haptics, feedback, taptic
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

// UIKit haptics for more control
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
| `.light` | Subtle feedback |
| `.medium` | Standard button |
| `.heavy` | Significant action |

Reference: [Playing haptics - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)
