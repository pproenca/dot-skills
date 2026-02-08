---
title: Replace Callback Closures with PreferenceKey
impact: HIGH
impactDescription: eliminates imperative callback chains, enables declarative data flow
tags: view, preference-key, callbacks, declarative, data-flow
---

## Replace Callback Closures with PreferenceKey

Passing closures from child to parent to communicate layout data (sizes, offsets, anchor points) creates imperative coupling that fights against SwiftUI's declarative model. PreferenceKey lets child views declaratively attach values that bubble up the view tree, and parents read them with `.onPreferenceChange`. This keeps the data flow unidirectional and composable, working naturally with SwiftUI's layout system.

**Incorrect (imperative closure callback couples child to parent):**

```swift
struct CollapsibleHeader: View {
    @State private var headerHeight: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack {
                HeaderContent(onHeightChanged: { height in
                    headerHeight = height
                })
                ContentBody()
            }
        }
        .overlay(alignment: .top) {
            StickyBar(collapseAt: headerHeight)
        }
    }
}

struct HeaderContent: View {
    var onHeightChanged: (CGFloat) -> Void

    var body: some View {
        VStack {
            Text("Welcome Back").font(.largeTitle)
            Text("Your dashboard is ready").font(.subheadline)
        }
        .background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    onHeightChanged(geometry.size.height)
                }
            }
        )
    }
}
```

**Correct (PreferenceKey propagates data declaratively up the tree):**

```swift
struct HeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct CollapsibleHeader: View {
    @State private var headerHeight: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack {
                HeaderContent()
                ContentBody()
            }
        }
        .onPreferenceChange(HeaderHeightKey.self) { height in
            headerHeight = height
        }
        .overlay(alignment: .top) {
            StickyBar(collapseAt: headerHeight)
        }
    }
}

struct HeaderContent: View {
    var body: some View {
        VStack {
            Text("Welcome Back").font(.largeTitle)
            Text("Your dashboard is ready").font(.subheadline)
        }
        .background(
            GeometryReader { geometry in
                Color.clear.preference(key: HeaderHeightKey.self,
                                       value: geometry.size.height)
            }
        )
    }
}
```

Reference: [PreferenceKey](https://developer.apple.com/documentation/swiftui/preferencekey)
