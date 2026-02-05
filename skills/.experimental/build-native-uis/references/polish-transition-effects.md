---
title: Apply Transition Effects for View Insertion and Removal
impact: LOW
impactDescription: transitions animate views appearing and disappearing, preventing jarring UI changes
tags: polish, transition, animation, insertion, removal
---

## Apply Transition Effects for View Insertion and Removal

When views are conditionally added or removed from the hierarchy, they pop in and out without any visual cue by default. Adding `.transition()` modifiers animates the insertion and removal, giving users a clear signal that content has appeared or disappeared.

**Incorrect (notification banner appears and disappears abruptly):**

```swift
struct ContentView: View {
    @State private var showBanner = false

    var body: some View {
        ZStack(alignment: .top) {
            MainFeedView()
            if showBanner {
                NotificationBanner(message: "Item saved successfully")
                    .padding(.top, 8)
            }
        }
    }
}
```

**Correct (transition animates the banner sliding in and fading out):**

```swift
struct ContentView: View {
    @State private var showBanner = false

    var body: some View {
        ZStack(alignment: .top) {
            MainFeedView()
            if showBanner {
                NotificationBanner(message: "Item saved successfully")
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity)) // slides in from top and fades
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showBanner)
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
