---
title: Keep View extensions and modifiers free of runtime branches
tags: identity, view-modifiers, applyif, structural-identity
---

## Keep View extensions and modifiers free of runtime branches

The wrong default is an `if/else` or `if let` inside a `View` extension or `ViewModifier` that responds to runtime state — including the ubiquitous generic `applyIf(_:transform:)` helper. Even when both branches render the same content, the compiler sees two distinct types, so SwiftUI sees two view hierarchies and resets the identity and lifetime of everything the modifier wraps each time the condition toggles. The worst case is a high-level container: one toggle of a `.themed(color:)` modifier on a `TabView` destroys the container and every tab inside it — transient state is lost, data may reload, and navigation state may reset. A generic `applyIf` helper is more dangerous still, because it hides the branch at every call site, making the resulting animation and state-loss bugs hard to trace.

**Evidence of violation:** an `if/else` or `if let` inside a `View` extension body, a `ViewModifier` `body(content:)`, or any generic conditional helper (e.g. `applyIf`, `if(_:transform:)`) where the branches return structurally different chains and the condition is a runtime value (a parameter, `@State`, or a changeable `@Environment` value). Both the declaration of such a generic helper and any call site of one count as violations. PASS: a single stable chain using ternaries or Bool/optional-aware modifier parameters (`.bold(flag)`, `.tint(optionalColor)`, `.foregroundStyle(flag ? .green : .primary)`). PASS (carve-out): branches on compile-time or launch-stable conditions only — `#if os(...)` and `if #available` — which cannot change during execution, so identity is stable; the carve-out is claimed by pointing at the `#if`/`#available` keyword itself. N/A: no conditional logic inside modifier helpers in the target.

**Incorrect (one theme change destroys the TabView and every tab's state; applyIf hides the same branch at every call site):**

```swift
import SwiftUI

extension View {
    // ⚠️ Identity loss on a high-level container
    @ViewBuilder
    func themed(color: Color?) -> some View {
        if let color {
            self.tint(color)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyIf<V: View>(
        _ condition: Bool,
        transform: (Self) -> V
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct MainTabView: View {
    @State private var themeColor: Color?

    var body: some View {
        TabView {
            // Multiple tabs with their own states
            Text("Animals")
            Text("Habitats")
        }
        .themed(color: themeColor)
    }
}
```

**Correct (optional-aware and Bool-parameter modifiers keep one stable chain — only attribute values change):**

```swift
import SwiftUI

extension View {
    func themed(color: Color?) -> some View {
        self.tint(color)
    }

    func highlighted(_ isHighlighted: Bool = true) -> some View {
        self
            .bold(isHighlighted)
            .underline(isHighlighted)
            .foregroundStyle(isHighlighted ? .green : .primary)
    }
}

struct MainTabView: View {
    @State private var themeColor: Color?

    var body: some View {
        TabView {
            // Multiple tabs with their own states
            Text("Animals")
            Text("Habitats")
        }
        .themed(color: themeColor)
    }
}
```
