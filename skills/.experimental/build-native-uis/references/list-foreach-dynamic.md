---
title: Use ForEach for Dynamic Content in Containers
impact: MEDIUM-HIGH
impactDescription: ForEach generates views from collections inside any container, not just List
tags: list, foreach, dynamic-content, containers, hstack
---

## Use ForEach for Dynamic Content in Containers

ForEach is not limited to List; it generates views from a collection inside any container like HStack, VStack, or LazyVGrid. Manually duplicating views for each item creates rigid layouts that cannot adapt when the data changes. ForEach keeps the UI in sync with the underlying collection and eliminates repetitive code.

**Incorrect (manually repeating views for each tag):**

```swift
struct TagCloudView: View {
    let tags = ["Swift", "iOS", "SwiftUI", "Xcode"]

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                Text("Swift").padding(8).background(.blue.opacity(0.2)).clipShape(Capsule())
                Text("iOS").padding(8).background(.blue.opacity(0.2)).clipShape(Capsule())
                Text("SwiftUI").padding(8).background(.blue.opacity(0.2)).clipShape(Capsule())
                Text("Xcode").padding(8).background(.blue.opacity(0.2)).clipShape(Capsule()) // breaks when tags change
            }
        }
    }
}
```

**Correct (using ForEach with collection in HStack):**

```swift
struct TagCloudView: View {
    let tags = ["Swift", "iOS", "SwiftUI", "Xcode"]

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(tags, id: \.self) { tag in // generates a chip for each tag dynamically
                    Text(tag)
                        .padding(8)
                        .background(.blue.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
