---
title: Keep View extensions and modifiers free of runtime branches
tags: identity, view-modifiers, applyif, structural-identity
---

## Keep View extensions and modifiers free of runtime branches

The wrong default is an `if/else` inside a `View` extension or `ViewModifier` that responds to runtime state — including the ubiquitous generic `applyIf(_:transform:)` helper. Each branch is a distinct type in the compiler's eyes, so SwiftUI sees two view hierarchies and resets the identity and lifetime of the modified view every time the condition toggles. Applied to a high-level container, one toggle destroys the container and everything inside it: transient state is lost, data may reload, and navigation state may reset. The generic helper is worse because it hides the branch at every call site.

**Evidence of violation:** an `if/else` or `if let` inside a `View` extension, a `ViewModifier` `body`, or a generic conditional helper (e.g. `applyIf`), where the branches return differently-typed hierarchies and the condition is runtime state (a parameter, `@State`, or a changeable `@Environment` value). PASS: a single stable modifier chain using ternaries or Bool/optional-parameterized modifiers (`.bold(flag)`, `.foregroundStyle(flag ? .green : .primary)`). PASS: branches on compile-time or launch-time conditions only (`#if os(...)`, `if #available`) — these cannot change during execution, so identity is stable. N/A: no conditional logic inside modifier helpers in the target.

**Incorrect (every toggle of the condition resets the modified view's lifetime):**

```swift
import SwiftUI

extension View {
    @ViewBuilder
    func applyIf<V: View>(_ condition: Bool, transform: (Self) -> V) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
```

**Correct (one stable chain — only attribute values change):**

```swift
import SwiftUI

extension View {
    func highlighted(_ isHighlighted: Bool = true) -> some View {
        self
            .bold(isHighlighted)
            .underline(isHighlighted)
            .foregroundStyle(isHighlighted ? .green : .primary)
    }
}
```

Reference: expert SwiftUI reference (2026), “Encapsulating logic with view modifiers”.
