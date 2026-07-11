---
title: Mark fatalError-only overrides @available unavailable
tags: api, inheritance, unavailable, compile-time-safety
---

## Mark fatalError-only overrides @available unavailable

The wrong default — reinforced by the Xcode template — is overriding an inherited initializer or method with a bare `fatalError(...)` stub, the classic instance being `required init?(coder:) { fatalError("init(coder:) has not been implemented") }`. That stub compiles at every call site and defers the misuse to a runtime crash. Adding `@available(*, unavailable)` turns the same misuse into a compile-time error with a clear message, and directs developers toward the initializer the type is actually designed for.

**Evidence of violation:** an inherited initializer or method overridden with a body that only calls `fatalError(...)` (a "never call this" stub) and carries no `@available(*, unavailable)` attribute. PASS when the stub is annotated `@available(*, unavailable, message: ...)`, or when the override has a real implementation. N/A when no fatalError-only overrides exist in the target.

**Incorrect (misuse compiles and crashes at runtime):**

```swift
final class ChartLegendView: UIView {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(seriesNames: [String]) {
        super.init(frame: .zero)
    }
}
```

**Correct (misuse is a compile-time error with a clear message):**

```swift
final class ChartLegendView: UIView {
    @available(
        *, unavailable,
        message: "ChartLegendView is not designed to be initialized from a storyboard."
    )
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(seriesNames: [String]) {
        super.init(frame: .zero)
    }
}
```

Reference: expert Swift reference (2025), “Prevent misuse of irrelevant inherited functionalities in subclasses”
