---
title: Use @ViewBuilder for Flexible Composition
impact: HIGH
impactDescription: enables container views and conditional content
tags: view, viewbuilder, composition, container, generics
---

## Use @ViewBuilder for Flexible Composition

@ViewBuilder lets you create container views that accept arbitrary content, just like SwiftUI's built-in VStack and HStack.

**Incorrect (limited single-view parameter):**

```swift
struct Card: View {
    let content: AnyView  // Type erased, inflexible

    var body: some View {
        content
            .padding()
            .background(.background.secondary)
            .cornerRadius(12)
    }
}

// Usage is awkward
Card(content: AnyView(Text("Hello")))
```

**Correct (@ViewBuilder for flexible content):**

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

// Usage is natural
Card {
    VStack(alignment: .leading) {
        Text("Title")
            .font(.headline)
        Text("Description")
            .font(.body)
    }
}
```

**@ViewBuilder in computed properties:**

```swift
struct ConditionalContent: View {
    let showDetails: Bool

    var body: some View {
        VStack {
            header
            mainContent
        }
    }

    @ViewBuilder
    private var header: some View {
        if showDetails {
            DetailedHeader()
        } else {
            CompactHeader()
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        Text("Main content")
        if showDetails {
            Text("Additional details")
        }
    }
}
```

**Container with multiple slots:**

```swift
struct PageLayout<Header: View, Content: View, Footer: View>: View {
    let header: Header
    let content: Content
    let footer: Footer

    init(
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.header = header()
        self.content = content()
        self.footer = footer()
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            content.frame(maxHeight: .infinity)
            footer
        }
    }
}
```

Reference: [ViewBuilder Documentation](https://developer.apple.com/documentation/swiftui/viewbuilder)
