---
title: Use @Observable for Model Classes
impact: CRITICAL
impactDescription: eliminates ObservableObject boilerplate, enables granular updates
tags: state, observable, observation, ios17, data-flow
---

## Use @Observable for Model Classes

The @Observable macro (iOS 17+) replaces ObservableObject with automatic property tracking. SwiftUI only re-renders views that read changed properties, not the entire observation graph.

**Incorrect (ObservableObject triggers full re-renders):**

```swift
class UserProfile: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var avatarURL: URL?
    // Every @Published change re-renders ALL observing views
}

struct ProfileView: View {
    @StateObject var profile = UserProfile()

    var body: some View {
        VStack {
            Text(profile.name)  // Re-renders when email changes too
            Text(profile.email)
        }
    }
}
```

**Correct (granular property tracking):**

```swift
@Observable
class UserProfile {
    var name: String = ""
    var email: String = ""
    var avatarURL: URL?
    // SwiftUI tracks which properties each view reads
}

struct ProfileView: View {
    @State var profile = UserProfile()

    var body: some View {
        VStack {
            Text(profile.name)  // Only re-renders when name changes
            Text(profile.email) // Only re-renders when email changes
        }
    }
}
```

**Migration guide:**
- `ObservableObject` → `@Observable`
- Remove all `@Published` wrappers
- `@StateObject` → `@State`
- `@ObservedObject` → remove wrapper (just pass the object)
- `@EnvironmentObject` → `@Environment(MyType.self)`

Reference: [SwiftUI Data Flow with Observation](https://www.swiftyplace.com/blog/swiftui-observation)
