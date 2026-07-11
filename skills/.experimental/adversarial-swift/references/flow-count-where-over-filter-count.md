---
title: Count matching elements with count(where:) instead of filter then count
tags: flow, sequences, allocations, swift-six
---

## Count matching elements with count(where:) instead of filter then count

The wrong default for "how many elements match" is `collection.filter { … }.count`, which materializes a full intermediate array only to read its length and throw it away. Swift 6's `count(where:)` combines the test and the count in a single pass over the sequence with no allocation, and states the intent directly.

**Evidence of violation:** a `.filter { predicate }.count` chain on any `Sequence` where the result is used only as a count — the filtered array itself is never stored or reused. PASS: `.count(where: predicate)`, or a `lazy.filter { }.count` chain that avoids the allocation. N/A: the toolchain is older than Swift 6.0 (where `count(where:)` landed in the standard library), or the filtered array is also used for something beyond counting.

**Incorrect (allocates a throwaway array just to read its length):**

```swift
let temperatures = [-5, 10, -2, 20, 25, -1]

let aboveFreezingCount = temperatures.filter { $0 > 0 }.count
```

**Correct (one pass, no intermediate allocation):**

```swift
let temperatures = [-5, 10, -2, 20, 25, -1]

let aboveFreezingCount = temperatures.count { $0 > 0 }
```

Reference: *Swift Gems* (Natalia Panferova, Nil Coalescing, updated Nov 2025), “Efficiently count the number of elements that pass a test”.
