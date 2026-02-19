---
title: Migrate @StateObject to @State with @Observable
impact: CRITICAL
impactDescription: eliminates ObservableObject broadcast — only views reading changed property re-render
tags: state, stateobject, observable, migration, ios17
---

## Migrate @StateObject to @State with @Observable

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

`@StateObject` belongs to the `ObservableObject` protocol, which broadcasts ALL property changes to ALL subscribing views. With `@Observable` (iOS 26 / Swift 6.2), `@State` replaces `@StateObject` for ViewModel ownership, and `@Environment` replaces `@EnvironmentObject` for injection. The ownership semantics are identical — `@State` creates and retains the instance across view rebuilds — but observation is now property-level instead of whole-object.

**Incorrect (@StateObject + @EnvironmentObject — legacy ObservableObject pattern):**

```swift
@main
struct MyApp: App {
    @StateObject private var store = AnalyticsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

struct DashboardTab: View {
    @EnvironmentObject var store: AnalyticsStore
    // Runtime crash if .environmentObject(store) is missing
    // ALL views re-render when ANY @Published property changes

    var body: some View {
        DashboardCharts(store: store)
    }
}
```

**Correct (@State + @Environment with @Observable — compile-time safety, targeted re-renders):**

```swift
@Observable
class AnalyticsStore {
    var events: [AnalyticsEvent] = []
    var isProcessing: Bool = false
    var lastSyncDate: Date?

    func track(_ event: AnalyticsEvent) {
        events.append(event)
    }
}

@main
struct MyApp: App {
    @State private var store = AnalyticsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}

struct DashboardTab: View {
    @Environment(AnalyticsStore.self) private var store
    // Compile-time type verification
    // Only re-renders when properties THIS view reads actually change

    var body: some View {
        DashboardCharts(events: store.events)
    }
}
```

**Migration checklist:**
- `@StateObject` → `@State`
- `@EnvironmentObject` → `@Environment`
- `.environmentObject()` → `.environment()`
- `ObservableObject` → `@Observable`
- `@Published var` → plain `var`

Reference: [Migrating from the Observable Object protocol to the Observable macro](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
