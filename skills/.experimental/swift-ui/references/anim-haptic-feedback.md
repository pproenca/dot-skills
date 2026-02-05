---
title: Add Haptic Feedback for Interactions
impact: MEDIUM-HIGH
impactDescription: reinforces UI actions with tactile confirmation
tags: anim, haptics, feedback, interaction, touch
---

## Add Haptic Feedback for Interactions

Haptics provide tactile confirmation of actions. Use them for selection changes, success/error states, and significant interactions.

**Incorrect (no tactile feedback):**

```swift
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

**Correct (haptic on selection):**

```swift
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

**Best practices:**

```swift
struct HapticButton: View {
    let action: () -> Void

    var body: some View {
        Button("Submit") {
            // Prepare generator for lower latency
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()

            action()
            generator.impactOccurred()
        }
    }
}
```

**When to use haptics:**
- Toggle/switch changes: .light impact
- Button confirmations: .medium impact
- Destructive actions: .warning notification
- Success states: .success notification
- Picker selection: .selectionChanged
- Pull to refresh trigger: .medium impact

Reference: [Human Interface Guidelines - Haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)
