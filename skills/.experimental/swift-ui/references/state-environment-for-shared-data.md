---
title: Use @Environment for Shared App Data
impact: CRITICAL
impactDescription: avoids prop drilling through view hierarchy
tags: state, environment, dependency-injection, shared-data
---

## Use @Environment for Shared App Data

@Environment provides dependency injection for data needed across many views. Avoids passing data through every intermediate view (prop drilling).

**Incorrect (prop drilling through hierarchy):**

```swift
struct AppView: View {
    @State var settings = AppSettings()

    var body: some View {
        TabView {
            HomeView(settings: settings)
            ProfileView(settings: settings)
        }
    }
}

struct HomeView: View {
    let settings: AppSettings

    var body: some View {
        FeedView(settings: settings)  // Must pass through
    }
}

struct FeedView: View {
    let settings: AppSettings

    var body: some View {
        PostView(settings: settings)  // And again...
    }
}
```

**Correct (environment injection):**

```swift
struct AppView: View {
    @State var settings = AppSettings()

    var body: some View {
        TabView {
            HomeView()
            ProfileView()
        }
        .environment(settings)  // Inject once at top
    }
}

struct PostView: View {
    @Environment(AppSettings.self) var settings  // Access anywhere

    var body: some View {
        Text(settings.userName)
    }
}
```

**System environment values:**

```swift
struct AdaptiveView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var typeSize
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        // Adapt to system settings
    }
}
```

Reference: [SwiftUI Data Flow 2023](https://troz.net/post/2023/swiftui-data-flow-2023/)
