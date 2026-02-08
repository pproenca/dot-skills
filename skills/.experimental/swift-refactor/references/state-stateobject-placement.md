---
title: Move @StateObject to App Root for Shared State
impact: CRITICAL
impactDescription: prevents accidental re-initialization on view rebuild
tags: state, stateobject, lifecycle, initialization, architecture
---

## Move @StateObject to App Root for Shared State

When @StateObject is declared inside a child view, SwiftUI creates a new instance of the observed object each time the view struct is created. If the parent view rebuilds, the child's @StateObject initializer runs again, silently replacing the existing object and losing all accumulated state. Moving @StateObject to the App struct (or the highest stable ancestor) ensures the object is initialized exactly once and survives child view rebuilds. The object can then be injected down via `.environmentObject`. With @Observable (iOS 17+), use @State at the App level and `.environment` instead.

**Incorrect (@StateObject in child view re-initializes on parent rebuild):**

```swift
struct ContentView: View {
    @State private var tabIndex = 0

    var body: some View {
        TabView(selection: $tabIndex) {
            // When tabIndex changes, SwiftUI may recreate
            // DashboardTab, causing a new AnalyticsStore
            DashboardTab()
                .tag(0)
            SettingsTab()
                .tag(1)
        }
    }
}

struct DashboardTab: View {
    @StateObject private var store = AnalyticsStore()

    var body: some View {
        DashboardCharts(store: store)
    }
}
```

**Correct (@StateObject at app root survives all child rebuilds):**

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

    var body: some View {
        DashboardCharts(store: store)
    }
}
```

Reference: [StateObject](https://developer.apple.com/documentation/swiftui/stateobject)
