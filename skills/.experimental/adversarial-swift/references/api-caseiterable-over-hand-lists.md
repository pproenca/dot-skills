---
title: Conform to CaseIterable instead of hand-maintaining case lists
tags: api, enums, caseiterable, synthesized-conformance
---

## Conform to CaseIterable instead of hand-maintaining case lists

The wrong default is hand-writing a static array literal that enumerates every case of an enum — for pickers, tests, or iteration — instead of conforming the enum to `CaseIterable`. The hand-written list silently goes stale the moment a case is added: the picker misses the new option and no diagnostic fires. Conformance makes the compiler synthesize `allCases`, so the collection is always current with the enum definition.

**Evidence of violation:** a static or global array literal whose elements are exactly the cases of an enum with no associated values, where that enum does not conform to `CaseIterable`. PASS when the enum declares `CaseIterable` and call sites use `allCases`. N/A when the enum has associated values (automatic synthesis is impossible there, so a manual `allCases` is required), or when the list is a deliberate subset — the subset intent must be citable in the artifact, e.g. a name like `featuredDirections` or a comment stating the restriction; an exhaustive list named `all` claims no subset intent and fails.

**Incorrect (adding a case leaves the list stale with no diagnostic):**

```swift
enum CompassDirection {
    case north, south, east, west
}

struct DirectionPicker {
    static let allDirections: [CompassDirection] = [
        .north, .south, .east, .west
    ]
}
```

**Correct (the compiler keeps allCases current with the enum definition):**

```swift
enum CompassDirection: CaseIterable {
    case north, south, east, west
}

struct DirectionPicker {
    static let allDirections = CompassDirection.allCases
}
```

Reference: *Swift Gems* (Natalia Panferova, Nil Coalescing, updated Nov 2025), “Generate a collection of all cases in an enum”
