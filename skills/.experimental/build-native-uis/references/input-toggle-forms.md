---
title: Use Toggle and Form for Settings Interfaces
impact: MEDIUM-HIGH
impactDescription: Form provides grouped list styling, Toggle provides standard on/off control
tags: input, toggle, form, settings, grouped-list
---

## Use Toggle and Form for Settings Interfaces

Form wraps its content in a grouped list style that matches the native iOS Settings app, and Toggle provides a standard on/off switch that users instantly recognize. Building a custom switch with buttons and manual state coloring produces an inconsistent look, misses accessibility traits like the switch role, and requires extra work to replicate the grouped section styling that Form gives you for free.

**Incorrect (custom switch implementation with buttons):**

```swift
struct NotificationSettingsView: View {
    @State private var pushEnabled = true
    @State private var emailEnabled = false
    @State private var soundEnabled = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Push Notifications")
                Spacer()
                Button(pushEnabled ? "ON" : "OFF") { // custom toggle with no switch accessibility role
                    pushEnabled.toggle()
                }
                .foregroundStyle(pushEnabled ? .green : .gray)
            }
            HStack {
                Text("Email Notifications")
                Spacer()
                Button(emailEnabled ? "ON" : "OFF") {
                    emailEnabled.toggle()
                }
                .foregroundStyle(emailEnabled ? .green : .gray)
            }
            HStack {
                Text("Sound")
                Spacer()
                Button(soundEnabled ? "ON" : "OFF") {
                    soundEnabled.toggle()
                }
                .foregroundStyle(soundEnabled ? .green : .gray)
            }
        }
        .padding()
    }
}
```

**Correct (using Form with Toggle for native settings layout):**

```swift
struct NotificationSettingsView: View {
    @State private var pushEnabled = true
    @State private var emailEnabled = false
    @State private var soundEnabled = true

    var body: some View {
        Form { // provides grouped list styling matching iOS Settings
            Section("Alerts") {
                Toggle("Push Notifications", isOn: $pushEnabled)
                Toggle("Email Notifications", isOn: $emailEnabled)
            }
            Section("Preferences") {
                Toggle("Sound", isOn: $soundEnabled) // standard switch with accessibility support
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
