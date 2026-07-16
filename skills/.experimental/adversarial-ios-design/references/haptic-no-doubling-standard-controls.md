---
title: Do not add haptics to standard controls that already play them
tags: haptic, standard-controls, doubling, system-haptics
---

## Do not add haptics to standard controls that already play them

The wrong default is decorating a `Picker`, `Toggle`, or `Slider` with `.sensoryFeedback(.selection, …)` "for feel." Standard iOS controls — switches, sliders, pickers, segmented controls, pull-to-refresh — already play Apple-designed system haptics tuned to their interaction; adding a second haptic keyed to the same value change means the user feels two overlapping taps for one action, which reads as a hardware glitch rather than polish.

**Evidence of violation:** a `.sensoryFeedback` modifier or feedback-generator call whose trigger is the bound value of a standard `Picker`, `Toggle`, `Slider`, segmented control (`Picker` with `.segmented` style), or a `refreshable` action. Cite the modifier and the standard control whose binding it duplicates. PASS: standard controls left with their built-in haptics; custom haptics appear only on custom controls and gestures the system does not provide feedback for — cite the control types checked. N/A: the target adds no haptic feedback to any view.

**Incorrect (the Toggle plays its own switch haptic — this adds a second one on top):**

```swift
import SwiftUI

struct NotificationSettingsView: View {
    @State private var remindersEnabled = false

    var body: some View {
        Form {
            Toggle("Daily Reminders", isOn: $remindersEnabled)
                // ⚠️ Toggle already plays a system haptic — the user feels two
                .sensoryFeedback(.selection, trigger: remindersEnabled)
        }
    }
}
```

**Correct (the standard control keeps its built-in feedback; custom haptics go to the custom gesture):**

```swift
import SwiftUI

struct NotificationSettingsView: View {
    @State private var remindersEnabled = false
    @State private var snoozedUntilTomorrow = false

    var body: some View {
        Form {
            Toggle("Daily Reminders", isOn: $remindersEnabled)

            ReminderCard()
                .onLongPressGesture {
                    snoozedUntilTomorrow = true
                }
                .sensoryFeedback(.impact, trigger: snoozedUntilTomorrow) { _, newValue in
                    newValue
                }
        }
    }
}

struct ReminderCard: View {
    var body: some View {
        Label("Hold to snooze until tomorrow", systemImage: "moon.zzz")
    }
}
```

Reference: [Human Interface Guidelines — Playing haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)
