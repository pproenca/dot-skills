---
title: Use NavigationPath for Programmatic Navigation
impact: HIGH
impactDescription: enables pop-to-root, deep linking, and state restoration in one object
tags: nav, navigationpath, programmatic, state-restoration, deep-linking
---

## Use NavigationPath for Programmatic Navigation

Managing navigation with individual `@State` booleans does not compose: each new screen requires another boolean, you cannot pop to the root in one call, you cannot encode a deep link as a sequence of destinations, and you cannot persist and restore the navigation stack across app launches. `NavigationPath` replaces all of those booleans with a single type-erased stack that supports `append`, `removeLast`, and `Codable` serialization for state restoration.

**Incorrect (boolean flags for each navigation destination):**

```swift
struct HomeView: View {
    @State private var isShowingDetail = false
    @State private var isShowingSettings = false
    @State private var selectedItem: Item?

    var body: some View {
        NavigationStack {
            List(items) { item in
                Button(item.name) {
                    selectedItem = item
                    isShowingDetail = true
                }
            }
            .navigationDestination(isPresented: $isShowingDetail) {
                if let selectedItem {
                    ItemDetailView(item: selectedItem)
                }
            }
            .navigationDestination(isPresented: $isShowingSettings) {
                SettingsView()
            }
            // Cannot pop to root without resetting every boolean
            // Cannot encode navigation state for deep links
        }
    }
}
```

**Correct (NavigationPath for unified programmatic control):**

```swift
struct HomeView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List(items) { item in
                NavigationLink(value: item) {
                    Text(item.name)
                }
            }
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(item: item)
            }
            .navigationDestination(for: SettingsRoute.self) { _ in
                SettingsView()
            }
            .toolbar {
                Button("Settings") { path.append(SettingsRoute()) }
            }
        }
        // Pop to root: path.removeLast(path.count)
        // Deep link: path.append(item); path.append(SettingsRoute())
        // State restoration: encode/decode path via Codable
    }
}
```

Reference: [NavigationPath](https://developer.apple.com/documentation/swiftui/navigationpath)
