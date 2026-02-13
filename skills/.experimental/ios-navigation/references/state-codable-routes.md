---
title: Make Route Enums Codable for Navigation Persistence
impact: MEDIUM-HIGH
impactDescription: enables state restoration across app launches and scene changes
tags: state, codable, hashable, route, persistence
---

## Make Route Enums Codable for Navigation Persistence

`NavigationPath` can only be serialized (via its `Codable` representation) when every type pushed onto the stack conforms to `Codable`. If any route contains a non-Codable value — like `UIImage`, `NSObject`, or a view model reference — the entire path becomes non-serializable, breaking `SceneStorage` persistence and state restoration. Design routes around identifiers and primitive types, not runtime objects.

**Incorrect (non-Codable associated values break serialization):**

```swift
// BAD: UIImage does not conform to Codable.
// NavigationPath.CodableRepresentation will be nil,
// and SceneStorage persistence silently fails.
enum Route: Hashable {
    case profile(user: User)
    case photoDetail(image: UIImage)    // UIImage is NOT Codable
    case settings(controller: SettingsController)  // Class reference, NOT Codable

    // Even if you add Codable conformance to the enum,
    // the compiler rejects it because UIImage and
    // SettingsController don't conform to Codable.
}

struct User: Hashable {
    let id: String
    let name: String
    let avatar: UIImage  // Non-Codable property infects the whole type
}

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            // ...
        }
        .onChange(of: path) { _, newPath in
            // This returns nil because Route contains non-Codable types.
            // State restoration is silently broken — no compiler warning.
            let data = try? JSONEncoder().encode(newPath.codable)
            // data is nil. User loses navigation state on every app relaunch.
        }
    }
}
```

**Correct (Codable route enum with identifier-based associated values):**

```swift
// All associated values are primitive or Codable types.
// Use identifiers to reference objects, not the objects themselves.
enum Route: Hashable, Codable {
    case profile(userId: String)
    case photoDetail(photoId: String)
    case settings
    case orderDetail(orderId: String, tab: OrderTab)

    // Nested enums also need Codable + Hashable.
    enum OrderTab: String, Hashable, Codable {
        case summary, tracking, receipt
    }
}

// User model uses only Codable-safe types.
// Avatar is a URL string, not a UIImage.
struct User: Hashable, Codable {
    let id: String
    let name: String
    let avatarURL: URL  // URL is Codable — resolve to UIImage at display time
}

struct ContentView: View {
    @State private var path = NavigationPath()
    // SceneStorage works because NavigationPath.CodableRepresentation
    // succeeds when all pushed types are Codable.
    @SceneStorage("navigation") private var pathData: Data?

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .profile(let userId):
                        // Fetch the full User object on navigation,
                        // not stored in the route.
                        ProfileView(userId: userId)
                    case .photoDetail(let photoId):
                        PhotoDetailView(photoId: photoId)
                    case .settings:
                        SettingsView()
                    case .orderDetail(let orderId, let tab):
                        OrderDetailView(orderId: orderId, initialTab: tab)
                    }
                }
        }
        // Persist navigation path to SceneStorage on change.
        .onChange(of: path) { _, newPath in
            pathData = try? JSONEncoder().encode(newPath.codable)
        }
        // Restore navigation path from SceneStorage on launch.
        .onAppear {
            guard let data = pathData,
                  let codable = try? JSONDecoder().decode(
                      NavigationPath.CodableRepresentation.self, from: data
                  ) else { return }
            path = NavigationPath(codable)
        }
    }
}
```
