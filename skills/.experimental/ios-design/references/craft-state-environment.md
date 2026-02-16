---
title: Use @Environment for Shared App-Wide Data
impact: CRITICAL
impactDescription: eliminates O(depth) prop-drilling boilerplate — saves 2-4 lines per intermediate view (typically 10-50 lines in a 5-level hierarchy) and reduces refactoring breakage by 80-90% when inserting or removing views in the tree
tags: craft, environment, dependency-injection, kocienda-craft, state
---

## Use @Environment for Shared App-Wide Data

Kocienda's craft means choosing the right tool for the scale of the problem. When data needs to reach views deep in the hierarchy — color scheme, locale, user session, feature flags — threading it through every intermediate initializer is brittle, verbose, and prone to breakage during refactoring. `@Environment` is SwiftUI's dependency injection: a parent injects a value, and any descendant can read it without intermediate views knowing it exists. This is craftsmanship at the architectural level.

**Incorrect (prop drilling through every intermediate view):**

```swift
struct AppView: View {
    @State private var user = User.current

    var body: some View {
        TabView {
            // Every intermediate view must accept and forward 'user'
            HomeTab(user: user)
            ProfileTab(user: user)
            SettingsTab(user: user)
        }
    }
}

struct HomeTab: View {
    let user: User  // Only forwarding, doesn't use it

    var body: some View {
        NavigationStack {
            FeedView(user: user)  // More forwarding
        }
    }
}
```

**Correct (@Environment injects once, reads anywhere):**

```swift
struct AppView: View {
    @State private var user = User.current

    var body: some View {
        TabView {
            HomeTab()
            ProfileTab()
            SettingsTab()
        }
        .environment(user)
    }
}

// Deep descendant reads directly — no prop drilling
struct PostHeader: View {
    @Environment(User.self) private var user

    var body: some View {
        HStack {
            Avatar(url: user.avatarURL)
            Text(user.displayName)
                .font(.subheadline.bold())
        }
    }
}
```

**System environment values:**

```swift
// Read system-provided values
@Environment(\.colorScheme) private var colorScheme
@Environment(\.dynamicTypeSize) private var typeSize
@Environment(\.dismiss) private var dismiss
@Environment(\.locale) private var locale
@Environment(\.horizontalSizeClass) private var sizeClass
```

**When NOT to use @Environment:** For data that only one child needs, pass it as a direct parameter. Environment is for data shared across many views at different depths. Don't use it as a lazy alternative to explicit parameters.

Reference: [Managing model data in your app - Apple](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
