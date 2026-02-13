---
title: Use @Environment with @Observable and @Bindable for Shared State
impact: HIGH
impactDescription: prevents EnvironmentObject crashes, enables type-safe dependency injection
tags: arch, observable, environment, bindable, dependency-injection
---

## Use @Environment with @Observable and @Bindable for Shared State

`@Observable` objects are injected with `.environment(object)` and read with `@Environment(Type.self)`. This replaces the legacy `.environmentObject(object)` / `@EnvironmentObject` pattern. To get `Binding` access to an `@Observable` object's properties (e.g., for `NavigationStack(path:)`), re-declare it as `@Bindable var` inside the `body` property. Using `@EnvironmentObject` with an `@Observable` class does not work — it requires `ObservableObject` conformance.

**Incorrect (@EnvironmentObject with @Observable — does not compile):**

```swift
@Observable
class AppCoordinator {
    var path: [Route] = []
    var presentedSheet: SheetDestination?
}

struct HomeView: View {
    // BAD: @EnvironmentObject requires ObservableObject conformance.
    // @Observable classes do NOT conform to ObservableObject.
    // This crashes at runtime with "No ObservableObject found."
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        // Cannot get Binding for NavigationStack path
        NavigationStack(path: $coordinator.path) { /* ... */ }
    }
}

struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            // BAD: .environmentObject() requires ObservableObject
            HomeView().environmentObject(AppCoordinator())
        }
    }
}
```

**Correct (@Environment + @Bindable for @Observable objects):**

```swift
@Observable
class AppCoordinator {
    var path: [Route] = []
    var presentedSheet: SheetDestination?

    func navigate(to route: Route) { path.append(route) }
    func popToRoot() { path.removeAll() }
}

struct HomeView: View {
    // Read @Observable from environment — type-safe, no protocol needed
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        // Re-declare as @Bindable to get Binding access
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            ProductGrid()
                .navigationDestination(for: Route.self) { route in
                    route.destinationView
                }
        }
        .sheet(item: $coordinator.presentedSheet) { sheet in
            sheet.content
        }
    }
}

struct MyApp: App {
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            // .environment() injects @Observable objects
            HomeView().environment(coordinator)
        }
    }
}
```
