---
title: Avoid AnyView for Type Erasure
impact: HIGH
impactDescription: AnyView disables SwiftUI's diffing optimization
tags: view, anyview, type-erasure, performance, generics
---

## Avoid AnyView for Type Erasure

AnyView erases type information, preventing SwiftUI from efficiently diffing views. Use `@ViewBuilder`, generics, or `Group` instead.

**Incorrect (AnyView breaks diffing):**

```swift
struct DynamicContent: View {
    let contentType: ContentType

    var body: some View {
        content  // Returns AnyView
    }

    var content: AnyView {
        switch contentType {
        case .text(let string):
            return AnyView(Text(string))  // Type erased
        case .image(let url):
            return AnyView(AsyncImage(url: url))  // Type erased
        case .video(let url):
            return AnyView(VideoPlayer(url: url))  // Type erased
        }
    }
}
```

**Correct (using @ViewBuilder):**

```swift
struct DynamicContent: View {
    let contentType: ContentType

    var body: some View {
        content
    }

    @ViewBuilder
    var content: some View {
        switch contentType {
        case .text(let string):
            Text(string)  // Type preserved
        case .image(let url):
            AsyncImage(url: url)  // Type preserved
        case .video(let url):
            VideoPlayer(url: url)  // Type preserved
        }
    }
}
```

**Alternative with Group:**

```swift
var body: some View {
    Group {
        if showImage {
            AsyncImage(url: imageURL)
        } else {
            Text(placeholder)
        }
    }
}
```

**When AnyView is acceptable:**
- Heterogeneous collections where type erasure is unavoidable
- Plugin systems with unknown view types
- Rarely-updated views where diffing cost is negligible

**Using generics instead:**

```swift
struct Card<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(.background.secondary)
            .cornerRadius(12)
    }
}
```

Reference: [SwiftUI Performance Best Practices](https://dev.to/arshtechpro/swiftui-performance-and-stability-avoiding-the-most-costly-mistakes-234c)
