---
title: Never Create State Inside the View Body
impact: CRITICAL
impactDescription: prevents infinite re-render loops and 100% state-loss bugs — eliminates O(n) per-frame allocations that cause 60fps drops to <1fps and memory leaks scaling at ~1 allocation per body call (60×/sec during animations)
tags: craft, state, body, kocienda-craft, performance, lifecycle
---

## Never Create State Inside the View Body

Kocienda's craft means understanding the runtime lifecycle beneath the syntax. The `body` property is a computed property that SwiftUI calls frequently — up to 120 times per second during animations (once per frame at 120Hz). Creating `@State`, `@StateObject`, or `@Observable` instances inside `body` means allocating new state on every evaluation, which can trigger a new evaluation, creating an infinite loop. This is the kind of subtle bug that works in previews but crashes in production. A craftsman initializes state at the declaration site, never inside the computation.

**Incorrect (state created in body — resets on every evaluation):**

```swift
struct SearchView: View {
    var body: some View {
        // New model created on EVERY body call
        let viewModel = SearchViewModel()

        VStack {
            TextField("Search", text: $viewModel.query)
            // Query resets to "" every time the parent re-renders
        }
    }
}
```

**Correct (state declared as stored property):**

```swift
struct SearchView: View {
    @State private var viewModel = SearchViewModel()

    var body: some View {
        VStack {
            TextField("Search", text: $viewModel.query)
            // Query persists across re-renders
        }
    }
}
```

**Other body-allocation traps:**

```swift
// Wrong: timer created on every body call
var body: some View {
    let timer = Timer.publish(every: 1, on: .main, in: .common)
    // Creates a NEW timer every re-render
}

// Right: declared as stored property or in onAppear
@State private var timer = Timer.publish(every: 1, on: .main, in: .common)

// Wrong: expensive computation in body without caching
var body: some View {
    let sortedItems = items.sorted(by: { $0.date > $1.date })
    // Re-sorts on every re-render
}

// Right: derive in the model or use a computed property outside body
var sortedItems: [Item] {
    items.sorted(by: { $0.date > $1.date })
}
```

**When it's acceptable:** Simple value computations that are cheap (`let fullName = "\(first) \(last)"`) are fine in body. The rule applies to stateful objects, timers, publishers, and expensive computations.

Reference: [Managing user interface state - Apple](https://developer.apple.com/documentation/swiftui/managing-user-interface-state)
