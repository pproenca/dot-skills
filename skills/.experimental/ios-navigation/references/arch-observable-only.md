---
title: Use @Observable Only — Never ObservableObject or @Published
impact: CRITICAL
impactDescription: 2-10x fewer view updates — only views reading changed property re-render
tags: arch, observable, state, ios17, migration
---

## Use @Observable Only — Never ObservableObject or @Published

`@Observable` (iOS 17+) tracks which properties each view reads in its body and only triggers re-render when THOSE specific properties change. `ObservableObject` with `@Published` triggers re-render for ANY property change on the object — even unrelated ones. In navigation coordinators this is catastrophic: changing `presentedSheet` re-renders every view observing the coordinator, even those only reading `path`.

**Incorrect (ObservableObject coordinator — all views re-render on any change):**

```swift
// ObservableObject notifies ALL subscribers when ANY @Published changes
// Changing presentedSheet re-renders views that only read path
class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var presentedSheet: SheetRoute?
    @Published var presentedAlert: AlertRoute?
}

struct OrderListView: View {
    @StateObject var coordinator = NavigationCoordinator()
    // When presentedSheet changes, this ENTIRE view re-renders
    // even though it only reads path

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            List { /* ... */ }
        }
    }
}
```

**Correct (@Observable coordinator — property-level tracking):**

```swift
// @Observable tracks which properties each view reads
// Changing presentedSheet does NOT re-render views only reading path
@Observable @MainActor
final class NavigationCoordinator {
    var path = NavigationPath()
    var presentedSheet: SheetRoute?
    var presentedAlert: AlertRoute?

    func navigate(to route: AppRoute) { path.append(route) }
    func popToRoot() { path = NavigationPath() }
}

@Equatable
struct OrderListView: View {
    @Environment(NavigationCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator
        NavigationStack(path: $coordinator.path) {
            List { /* ... */ }
        }
    }
}
```

**Key replacements:**
- `ObservableObject` → `@Observable`
- `@Published var` → plain `var`
- `@StateObject` → `@State`
- `@ObservedObject` → plain property
- `@EnvironmentObject` → `@Environment(Type.self)`
- `.environmentObject()` → `.environment()`

Reference: [WWDC23 — Discover Observation in SwiftUI](https://developer.apple.com/wwdc23/10149)
