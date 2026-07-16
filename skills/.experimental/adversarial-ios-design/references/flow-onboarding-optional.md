---
title: Keep onboarding optional and request permissions in context
tags: flow, onboarding, permissions, launch
---

## Keep onboarding optional and request permissions in context

The wrong default is a launch wall: a mandatory welcome carousel, a settings quiz, and a burst of permission dialogs before the user has seen a single screen of value. The HIG requires the opposite shape — "if onboarding is necessary, design a flow that's fast, fun, and optional," never re-shown after a skip, with defaults standing in for setup — and pushes permissions to their moment of use: "present a permission request when people first access the specific function that relies on private data or resources." A launch-time notification prompt has no context, so the reflexive answer is Don't Allow, permanently costing the app the capability it asked for too early.

**Evidence of violation:** an onboarding/welcome flow with no Skip or dismiss path before the app's primary content is reachable; onboarding shown again on later launches (no persisted has-seen flag such as an `@AppStorage` write on completion or skip); a permission request — `UNUserNotificationCenter.requestAuthorization`, `CLLocationManager.requestWhenInUseAuthorization`, ATT, camera/microphone — called from `App` init, the root view's `onAppear`/`.task`, or inside onboarding, for a capability the app functions without. Carve-out: a capability the app cannot function without (camera access in a camera app) may be requested during onboarding — the reviewer must cite the app's dependence on it; absent that evidence, fail closed. PASS: first launch reaches primary content with defaults; tutorials skippable and persisted; each permission requested at first use of the dependent feature. N/A: no onboarding flow and no permission requests in the target.

**Incorrect (a contextless notification prompt fires before the first screen renders):**

```swift
import SwiftUI
import UserNotifications

@main
struct HabitTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            HabitListView()
                .task {
                    // ⚠️ Launch-time permission request — no context, reflexive denial
                    try? await UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.alert, .badge, .sound])
                }
        }
    }
}
```

**Correct (the request fires when the user asks for the feature that needs it):**

```swift
import SwiftUI
import UserNotifications

struct HabitDetailView: View {
    @Bindable var habit: Habit

    var body: some View {
        Form {
            Toggle("Daily Reminder", isOn: $habit.reminderEnabled)
                .onChange(of: habit.reminderEnabled) { _, isOn in
                    guard isOn else { return }
                    Task {
                        let granted = try await UNUserNotificationCenter.current()
                            .requestAuthorization(options: [.alert, .badge, .sound])
                        if granted {
                            ReminderScheduler.schedule(for: habit)
                        } else {
                            habit.reminderEnabled = false
                        }
                    }
                }
        }
        .navigationTitle(habit.name)
    }
}
```

Reference: [HIG — Onboarding](https://developer.apple.com/design/human-interface-guidelines/onboarding)
