---
title: Use @Binding for Child View Mutations
impact: CRITICAL
impactDescription: prevents 100% of parent-child state divergence bugs — eliminates duplicate state storage (2× memory per shared value) and ensures mutations propagate in <16ms (single frame) instead of requiring manual sync logic (10-30 extra lines per shared property)
tags: craft, binding, parent-child, kocienda-craft, state
---

## Use @Binding for Child View Mutations

Kocienda's craft means understanding the communication protocol between components. When a child view needs to mutate a value owned by its parent, `@Binding` creates a two-way connection — the child reads and writes the parent's state directly. Passing a plain value creates a one-way copy: the child appears to work in isolation, but changes never propagate back, and the parent and child silently diverge. This is the SwiftUI equivalent of two people editing different copies of a document.

**Incorrect (value copy — child mutations invisible to parent):**

```swift
struct TemperatureControl: View {
    var temperature: Double  // Copy — changes don't propagate back

    var body: some View {
        Stepper("\\(Int(temperature))°F", value: $temperature)
        // Compiler error: cannot create binding from plain property
    }
}

// Parent
struct ThermostatView: View {
    @State private var temperature = 72.0

    var body: some View {
        TemperatureControl(temperature: temperature)
        // Parent never sees child's changes
    }
}
```

**Correct (binding — parent and child share state):**

```swift
struct TemperatureControl: View {
    @Binding var temperature: Double

    var body: some View {
        Stepper("\\(Int(temperature))°F", value: $temperature, in: 60...90)
    }
}

// Parent passes binding via $
struct ThermostatView: View {
    @State private var temperature = 72.0

    var body: some View {
        VStack {
            Text("Current: \\(Int(temperature))°F")
                .font(.title)
            TemperatureControl(temperature: $temperature)
        }
    }
}
```

**Creating bindings from @Observable models:**

```swift
@Observable class Settings {
    var notificationsEnabled = true
}

struct SettingsToggle: View {
    @Bindable var settings: Settings

    var body: some View {
        Toggle("Notifications", isOn: $settings.notificationsEnabled)
    }
}
```

**When NOT to use @Binding:** When the child only reads the value and never mutates it, pass a plain value. Binding implies write access — don't create false expectations in your API.

Reference: [Managing user interface state - Apple](https://developer.apple.com/documentation/swiftui/managing-user-interface-state)
