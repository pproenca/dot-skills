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
// BAD: UIImage and class references are NOT Codable
// NavigationPath.CodableRepresentation will be nil
enum Route: Hashable {
    case profile(user: User)
    case photoDetail(image: UIImage)    // UIImage NOT Codable
    case settings(controller: SettingsController)  // Class NOT Codable
}

struct User: Hashable {
    let id: String
    let name: String
    let avatar: UIImage  // Non-Codable property breaks serialization
}

struct ContentView: View {
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            // ...
        }
        .onChange(of: path) { _, newPath in
            // Returns nil because Route contains non-Codable types
            let data = try? JSONEncoder().encode(newPath.codable)
            // data is nil, navigation state lost on every relaunch
        }
    }
}
```

**Correct (Codable route enum with identifier-based associated values):**

```swift
// Use identifiers to reference objects, not the objects themselves
enum Route: Hashable, Codable {
    case profile(userId: String)
    case photoDetail(photoId: String)
    case settings
    case orderDetail(orderId: String, tab: OrderTab)
    enum OrderTab: String, Hashable, Codable {
        case summary, tracking, receipt
    }
}

struct User: Hashable, Codable {
    let id: String
    let name: String
    let avatarURL: URL  // URL is Codable, resolve to UIImage at display time
}

@Equatable
struct ContentView: View {
    @State private var path = NavigationPath()
    @SceneStorage("navigation") private var pathData: Data?
    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .profile(let userId): ProfileView(userId: userId)
                    case .photoDetail(let photoId): PhotoDetailView(photoId: photoId)
                    case .settings: SettingsView()
                    case .orderDetail(let orderId, let tab):
                        OrderDetailView(orderId: orderId, initialTab: tab)
                    }
                }
        }
        .onChange(of: path) { _, newPath in
            pathData = try? JSONEncoder().encode(newPath.codable)
        }
        .onAppear {
            guard let data = pathData,
                  let codable = try? JSONDecoder().decode(NavigationPath.CodableRepresentation.self, from: data)
            else { return }
            path = NavigationPath(codable)
        }
    }
}
```
