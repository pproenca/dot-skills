---
title: Return some View from body Property
impact: CRITICAL
impactDescription: foundation of every SwiftUI view, defines view hierarchy, enables type system
tags: view, swiftui, view-protocol, opaque-type, struct, composition
---

## Return some View from body Property

Every SwiftUI view must be a struct conforming to the `View` protocol, which requires a computed `body` property returning `some View`. Without this contract the compiler cannot participate in the declarative diffing system, and the struct is just inert data. Use `some` (opaque return type) to let Swift infer the exact type.

**Incorrect (wrong body signature or missing conformance):**

```swift
struct ContentView: View {
    // Missing body property - won't compile
}

struct ContentView: View {
    var body: View {  // Wrong: must be 'some View'
        Text("Hello")
    }
}

struct ContentView: View {
    func body() -> some View {  // Wrong: must be computed property, not function
        Text("Hello")
    }
}

struct ProfileHeader {
    let username: String

    func render() -> Text {  // No View conformance
        Text(username)
            .font(.headline)
    }
}
```

**Correct (struct conforms to View with body property):**

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ProfileHeader: View {
    let username: String
    let avatarURL: URL

    var body: some View { // required by View protocol
        Text(username)
            .font(.headline)
    }
}

// Preview for canvas
#Preview {
    ContentView()
}
```

**View protocol requirements:**
- Import SwiftUI framework
- Conform struct to `View` protocol
- Implement `body` as computed property
- Return type must be `some View`
- Body should return a single view (use containers to combine multiple)

**Why `some View`:**
- Hides the complex concrete type
- Enables SwiftUI's diffing algorithm
- Allows composition without type erasure

Reference: [Develop in Swift Tutorials - Hello, SwiftUI](https://developer.apple.com/tutorials/develop-in-swift/hello-swiftui)
