---
title: Use SceneStorage for Per-Scene Navigation Persistence
impact: MEDIUM-HIGH
impactDescription: automatic state restoration per window, survives app termination
tags: state, scene-storage, persistence, multi-window
---

## Use SceneStorage for Per-Scene Navigation Persistence

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

`@SceneStorage` persists values per scene (window) and is managed by the system. Each iPad Split View window or Stage Manager window gets independent navigation state that survives app termination. Never use `@AppStorage` for navigation state — it writes to `UserDefaults`, which is shared across all scenes, causing every window to jump to the same destination when one navigates.

**Incorrect (@AppStorage for navigation — shared across all windows):**

```swift
struct RootView: View {
    @State private var path = NavigationPath()

    // BAD: @AppStorage writes to UserDefaults, which is shared
    // across ALL scenes. On iPad with two windows open:
    // - Window A navigates to Settings
    // - pathData is written to UserDefaults
    // - Window B reads the SAME pathData on next appear
    // - Window B jumps to Settings — user didn't navigate there
    @AppStorage("navigationPath") private var pathData: Data?

    // BAD: Same problem for tab selection.
    // Switching tabs in Window A switches tabs in Window B.
    @AppStorage("selectedTab") private var selectedTab = "home"

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $path) {
                HomeView()
                    .navigationDestination(for: Route.self) { route in
                        route.destination
                    }
            }
            .tag("home")
            .tabItem { Label("Home", systemImage: "house") }

            SettingsView()
                .tag("settings")
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .onChange(of: path) { _, newPath in
            pathData = try? JSONEncoder().encode(newPath.codable)
        }
    }
}
```

**Correct (@SceneStorage for per-window navigation persistence):**

```swift
@Equatable
struct RootView: View {
    @State private var path = NavigationPath()

    // @SceneStorage: each scene (window) gets its own storage.
    // iPad Window A and Window B have independent navigation paths.
    // System manages lifecycle — data persists across app termination
    // and is cleaned up when the scene is destroyed.
    @SceneStorage("navigationPath") private var pathData: Data?

    // Per-scene tab selection. Each window remembers its own tab.
    @SceneStorage("selectedTab") private var selectedTab = "home"

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $path) {
                HomeView()
                    .navigationDestination(for: Route.self) { route in
                        route.destination
                    }
            }
            .tag("home")
            .tabItem { Label("Home", systemImage: "house") }

            SettingsView()
                .tag("settings")
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        // Persist: encode NavigationPath to Data on every change.
        .onChange(of: path) { _, newPath in
            // .codable returns nil if any pushed type is not Codable.
            // See state-codable-routes rule for ensuring Codable conformance.
            guard let codable = newPath.codable else { return }
            pathData = try? JSONEncoder().encode(codable)
        }
        // Restore: decode Data back to NavigationPath on scene creation.
        .task {
            // .task runs once on appear — restore saved path.
            guard let data = pathData else { return }
            do {
                let codable = try JSONDecoder().decode(
                    NavigationPath.CodableRepresentation.self,
                    from: data
                )
                path = NavigationPath(codable)
            } catch {
                // Decoding failed — app update may have changed Route enum.
                // Clear stale data and start fresh.
                pathData = nil
            }
        }
    }
}
```
