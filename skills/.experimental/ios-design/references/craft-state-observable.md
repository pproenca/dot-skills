---
title: "Use @Observable for Model Classes"
impact: CRITICAL
impactDescription: "property-level change tracking eliminates 60-80% of unnecessary body evaluations — views only re-render when the specific property they read changes, compared to ObservableObject which re-renders all subscribers on any change"
tags: craft, observable, model, kocienda-craft, state, performance
---

## Use @Observable for Model Classes

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

Kocienda's craft demands using the best tool available, not the one you're used to. `@Observable` (iOS 26 / Swift 6.2) replaces `ObservableObject` with a fundamentally better observation model: property-level tracking. With `ObservableObject`, changing any `@Published` property re-evaluates every view that observes the object. With `@Observable`, only views that read the specific changed property re-evaluate. This is the kind of invisible craftsmanship that users feel in responsiveness without ever knowing why.

**Incorrect (ObservableObject — all subscribers re-render on any change):**

```swift
class BookingViewModel: ObservableObject {
    @Published var guestName = ""
    @Published var checkInDate = Date()
    @Published var checkOutDate = Date()
    @Published var specialRequests = ""

    // Changing guestName re-evaluates EVERY view that observes this object
    // even if they only read checkInDate
}

struct BookingForm: View {
    @StateObject private var viewModel = BookingViewModel()
    // ...
}
```

**Correct (@Observable — only affected views re-render):**

```swift
@Observable class BookingViewModel {
    var guestName = ""
    var checkInDate = Date()
    var checkOutDate = Date()
    var specialRequests = ""

    // Changing guestName only re-evaluates views that read guestName
}

struct BookingForm: View {
    @State private var viewModel = BookingViewModel()

    var body: some View {
        Form {
            // Only re-renders when guestName changes
            TextField("Guest Name", text: $viewModel.guestName)

            // Only re-renders when dates change
            DatePicker("Check In", selection: $viewModel.checkInDate)
            DatePicker("Check Out", selection: $viewModel.checkOutDate)
        }
    }
}
```

**Key differences from ObservableObject:**
- No `@Published` needed — all stored properties are automatically observed
- Use `@State` instead of `@StateObject` to own the instance
- Pass directly to child views — no `@ObservedObject` needed
- Use `@Bindable` when you need `$` binding syntax in a child view
- Computed properties are automatically tracked through their dependencies

**When NOT to use @Observable:** When targeting iOS 16 or earlier, continue using `ObservableObject`. For simple view-local state (a boolean toggle, a text field value), prefer `@State` over a full model class.

Reference: [Managing model data in your app - Apple](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
