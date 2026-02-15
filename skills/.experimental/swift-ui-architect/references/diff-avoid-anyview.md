---
title: Never Use AnyView — Use @ViewBuilder or Generic Constraints
impact: HIGH
impactDescription: AnyView destroys type information and prevents structural diffing
tags: diff, anyview, type-erasure, viewbuilder, generics
---

## Never Use AnyView — Use @ViewBuilder or Generic Constraints

`AnyView` erases the concrete view type, preventing SwiftUI from performing structural identity matching. The diff engine must tear down and recreate the entire subtree on every update. Use `@ViewBuilder` for conditional composition or generic constraints for heterogeneous view types.

**Incorrect (AnyView type erasure — full subtree teardown on every update):**

```swift
struct ContentSection: View {
    let style: SectionStyle

    var body: some View {
        sectionContent()
    }

    // AnyView destroys type information
    // SwiftUI can't structurally diff between branches
    func sectionContent() -> AnyView {
        switch style {
        case .hero:
            return AnyView(HeroView())
        case .grid:
            return AnyView(GridView())
        case .list:
            return AnyView(ListView())
        }
    }
}
```

**Correct (@ViewBuilder — SwiftUI can structurally diff each branch):**

```swift
struct ContentSection: View {
    let style: SectionStyle

    var body: some View {
        sectionContent
    }

    // @ViewBuilder preserves concrete types
    // SwiftUI tracks each branch independently
    @ViewBuilder
    var sectionContent: some View {
        switch style {
        case .hero:
            HeroView()
        case .grid:
            GridView()
        case .list:
            ListView()
        }
    }
}
```

**Alternative (generics for stored view properties):**

```swift
// Generic constraint preserves the concrete type
struct Card<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            content()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
```

Reference: [WWDC23 — Demystify SwiftUI Performance](https://developer.apple.com/wwdc23/10160)
