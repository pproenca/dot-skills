---
title: "Use @Environment for System and Shared Values"
impact: HIGH
impactDescription: "injects system settings and shared dependencies without prop drilling"
tags: state, swiftui, environment, dependency-injection, system-values
---

## Use @Environment for System and Shared Values

Manually passing system values like color scheme or dismiss actions through multiple view layers creates brittle coupling and verbose initializers. `@Environment` lets any view in the hierarchy read these values directly from the SwiftUI environment, keeping view APIs clean.

**Incorrect (prop drilling system values through every layer):**

```swift
struct DetailScreen: View {
    let colorScheme: ColorScheme
    let dismiss: () -> Void

    var body: some View {
        VStack {
            Text("Detail")
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            Button("Close") {
                dismiss()
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DetailScreen(colorScheme: colorScheme, dismiss: dismiss.callAsFunction)
    }
}
```

**Correct (@Environment reads values directly from the SwiftUI environment):**

```swift
struct DetailScreen: View {
    @Environment(\.colorScheme) private var colorScheme // injected by SwiftUI
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Detail")
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            Button("Close") {
                dismiss()
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        DetailScreen() // no manual passing needed
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
