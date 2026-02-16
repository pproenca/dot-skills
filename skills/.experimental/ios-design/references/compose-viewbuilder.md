---
title: Use @ViewBuilder for Flexible Slot-Based Composition
impact: HIGH
impactDescription: without @ViewBuilder, container views can only accept a single child — @ViewBuilder enables SwiftUI's natural multi-view composition syntax that makes APIs feel native
tags: compose, viewbuilder, container, kocienda-creative-selection, api
---

## Use @ViewBuilder for Flexible Slot-Based Composition

Kocienda's creative selection is about composition — combining small pieces into larger wholes. `@ViewBuilder` is SwiftUI's mechanism for this: it lets a container view accept multiple child views using the same natural syntax as SwiftUI's built-in containers (`VStack`, `List`, `Form`). Without it, your custom containers feel foreign; with it, they feel like first-class citizens of the framework.

**Incorrect (closure-based API that only accepts one view):**

```swift
struct Card: View {
    let content: AnyView  // Type-erased, loses performance

    var body: some View {
        content
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// Awkward to use
Card(content: AnyView(
    VStack {
        Text("Title")
        Text("Subtitle")
    }
))
```

**Correct (@ViewBuilder enables natural composition):**

```swift
struct Card<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// Natural SwiftUI syntax
Card {
    Text("Today's Summary")
        .font(.headline)

    Text("$12,430 revenue across 84 orders")
        .font(.subheadline)
        .foregroundStyle(.secondary)
}
```

**Multi-slot containers:**

```swift
struct DetailRow<Leading: View, Trailing: View>: View {
    @ViewBuilder let leading: Leading
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack {
            leading
            Spacer()
            trailing
                .foregroundStyle(.secondary)
        }
    }
}

// Multiple content slots
DetailRow {
    Label("Storage", systemImage: "externaldrive.fill")
} trailing: {
    Text("128 GB")
}
```

**When NOT to use @ViewBuilder:** When a view needs exactly one child of a specific type (e.g., `NavigationLink` needs a destination), use a typed parameter instead. @ViewBuilder is for containers that accept flexible content.

Reference: [ViewBuilder - Apple Documentation](https://developer.apple.com/documentation/swiftui/viewbuilder)
