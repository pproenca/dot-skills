---
title: "Use @Observable for Shared Model Classes"
impact: HIGH
impactDescription: "fine-grained observation updates only views that read changed properties"
tags: state, swiftui, observable, observation, model
---

## Use @Observable for Shared Model Classes

The legacy `ObservableObject` protocol with `@Published` triggers view updates whenever any published property changes, even those the view does not read. The `@Observable` macro introduced in iOS 17 enables fine-grained tracking so only views that actually read a changed property re-render.

**Incorrect (ObservableObject re-renders all observing views on any change):**

```swift
class AppSettings: ObservableObject {
    @Published var username = ""
    @Published var notificationsEnabled = true
    @Published var fontSize = 14.0
}

struct FontSettingsView: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        // re-renders when username or notificationsEnabled change too
        Stepper("Font Size: \(Int(settings.fontSize))", value: $settings.fontSize, in: 10...30)
    }
}
```

**Correct (@Observable tracks only the properties each view reads):**

```swift
@Observable
class AppSettings {
    var username = ""
    var notificationsEnabled = true
    var fontSize = 14.0
}

struct FontSettingsView: View {
    @Bindable var settings: AppSettings // enables $settings.property bindings

    var body: some View {
        // re-renders only when fontSize changes
        Stepper("Font Size: \(Int(settings.fontSize))", value: $settings.fontSize, in: 10...30)
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
