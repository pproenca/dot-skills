---
title: Derive enum Comparable from declaration order instead of hand-rolled ladders
tags: enum, comparable, synthesized-conformance, ordering
---

## Derive enum Comparable from declaration order instead of hand-rolled ladders

For an enum whose ordering is exactly its declaration order, the wrong default is hand-writing `static func <` — usually via a numeric `rank` helper switching over every case. The manual ladder silently desynchronizes when cases are added or reordered: the compiler accepts a ladder that no longer matches the declaration, and comparisons quietly rank the new case wrong. Declaring `: Comparable` and taking the synthesized conformance (Swift 5.3) tracks the declaration automatically; the manual version is pure boilerplate with a maintenance bug attached.

**Evidence of violation:** an enum with a manual `static func <` implementation (or a numeric ordering property used only for comparisons) whose ordering is identical to the enum's declaration order, where the enum has no associated values or all-`Comparable` associated values — the shapes synthesis covers. PASS: the enum declares `: Comparable` with no manual `<`, or the manual ordering demonstrably differs from declaration order. N/A: the intended ordering deliberately differs from declaration order — the manual implementation is then load-bearing, and synthesis cannot express it.

**Incorrect (the rank ladder must be hand-updated for every new case, with no diagnostic when forgotten):**

```swift
enum PlantGrowth: Comparable {
    case seed
    case sprout
    case flowering
    case fruiting

    private var rank: Int {
        switch self {
        case .seed: return 0
        case .sprout: return 1
        case .flowering: return 2
        case .fruiting: return 3
        }
    }

    static func < (lhs: PlantGrowth, rhs: PlantGrowth) -> Bool {
        lhs.rank < rhs.rank
    }
}
```

**Correct (the synthesized conformance follows declaration order automatically):**

```swift
enum PlantGrowth: Comparable {
    case seed
    case sprout
    case flowering
    case fruiting
}

let currentStage = PlantGrowth.sprout
let nextStage = PlantGrowth.flowering

// Use the automatically derived comparison logic
if currentStage < nextStage {
    print("The plant is still growing.")
}
```

**Alternative (synthesis also covers Comparable associated values):**

```swift
enum TaskPriority: Comparable {
    case low
    case medium
    case high

    // Associated value that is also `Comparable`
    case critical(level: Int)
}

let task1 = TaskPriority.high
let task2 = TaskPriority.critical(level: 5)
let task3 = TaskPriority.critical(level: 10)

// Compare tasks with different priorities
if task2 > task1 {
    print("Task 2 has a higher priority than task 1.")
}

// Compare tasks within the same category but with different levels
if task3 > task2 {
    print("Task 3 has a higher priority than task 2.")
}
```
