---
title: Give each tab its own NavigationStack
tags: nav, navigation-stack, tab-bar, state-preservation
---

## Give each tab its own NavigationStack

The wrong default is one `NavigationStack` wrapped around the whole `TabView`, or one shared path binding feeding every tab. With a single stack, switching tabs tears down the current section's navigation state — the user drills three levels into one tab, glances at another, and returns to find their place gone. Tab switching is defined by state preservation: each section keeps its own stack (and its own path binding when navigation is programmatic), so every tab resumes exactly where the user left it.

**Evidence of violation:** the nesting order `NavigationStack { TabView { ... } }`; a single `NavigationPath`/typed path `@State` bound into more than one tab's stack; or a selection `onChange` handler that appends to or resets another tab's path. PASS: `TabView { Tab { NavigationStack(path: $sectionPath) { ... } } }` — one stack, and one path binding if programmatic, per tab — cite the per-tab stacks. N/A: no `TabView` in the target.

**Incorrect (one stack around the TabView wipes section state on every switch):**

```swift
import SwiftUI

struct AtlasRootView: View {
    @State private var path = NavigationPath()

    var body: some View {
        // ⚠️ One NavigationStack shared by every tab — switching tabs resets it
        NavigationStack(path: $path) {
            TabView {
                Tab("Cities", systemImage: "building.2") { CityListView() }
                Tab("Trips", systemImage: "airplane") { TripListView() }
                Tab("Saved", systemImage: "bookmark") { SavedPlacesView() }
            }
        }
    }
}
```

**Correct (each tab owns its stack and resumes where the user left it):**

```swift
import SwiftUI

struct AtlasRootView: View {
    @State private var cityPath = NavigationPath()
    @State private var tripPath = NavigationPath()

    var body: some View {
        TabView {
            Tab("Cities", systemImage: "building.2") {
                NavigationStack(path: $cityPath) { CityListView() }
            }
            Tab("Trips", systemImage: "airplane") {
                NavigationStack(path: $tripPath) { TripListView() }
            }
            Tab("Saved", systemImage: "bookmark") {
                NavigationStack { SavedPlacesView() }
            }
        }
    }
}
```

Reference: [HIG — Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars), [Enhancing your app's content with tab navigation](https://developer.apple.com/documentation/swiftui/enhancing-your-app-content-with-tab-navigation)
