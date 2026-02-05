---
title: Return some View from Body Property
impact: CRITICAL
impactDescription: defines view hierarchy, enables SwiftUI's type system, required for all views
tags: view, swiftui, view, body, opaque-types, composition
---

## Return some View from Body Property

Every SwiftUI view must have a `body` computed property that returns `some View`. This is the view's content. Use `some` (opaque return type) to let Swift infer the exact type.

**Incorrect (wrong body signature):**

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
```

**Correct (proper View conformance):**

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
