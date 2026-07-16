---
title: Conform enums to CaseIterable instead of hand-maintained case lists
tags: enum, caseiterable, allcases, synthesized-conformance
---

## Conform enums to CaseIterable instead of hand-maintained case lists

The wrong default is maintaining a hand-written `static let all: [CompassDirection] = [.north, …]` array (or iterating over a hand-list at call sites) for an enum that could simply conform to `CaseIterable`. The hand list silently goes stale when a case is added — the compiler has no idea the array claims to be complete, so pickers, tests, and iteration quietly miss the new case. The synthesized `allCases` is always current with the enum definition at zero maintenance cost.

**Evidence of violation:** a static array or computed property that literally enumerates every case of an enum without associated values, on an enum that does not conform to `CaseIterable` — decidable by comparing the literal list against the enum's case list. PASS: the enum conforms to `CaseIterable` and call sites use `allCases`. N/A: the list is a deliberately partial or reordered subset (it is not an "all cases" list), or the enum has associated values — there the compiler cannot synthesize `allCases` and a manual implementation is the accepted form.

**Incorrect (the static list desynchronizes the day a fifth direction is added):**

```swift
enum CompassDirection {
    case north
    case south
    case east
    case west

    static let all: [CompassDirection] = [.north, .south, .east, .west]
}

print(CompassDirection.all)
```

**Correct (allCases is synthesized from the declaration and can never go stale):**

```swift
enum CompassDirection: CaseIterable {
    case north
    case south
    case east
    case west
}

/* Prints `[
    CompassDirection.north, CompassDirection.south,
    CompassDirection.east, CompassDirection.west
]` */
print(CompassDirection.allCases)
```

**Alternative (associated values — a manual allCases is the required form and passes):**

```swift
enum FeatureToggle: CaseIterable {
    case darkMode(isEnabled: Bool)
    case logging(isEnabled: Bool)

    static var allCases: [FeatureToggle] {
        return [
            .darkMode(isEnabled: true),
            .darkMode(isEnabled: false),
            .logging(isEnabled: true),
            .logging(isEnabled: false)
        ]
    }
}
```
