---
title: Accumulate collections with reduce(into:) rather than copying reduce
tags: flow, reduce, performance, collections
---

## Accumulate collections with reduce(into:) rather than copying reduce

The wrong default for building a dictionary or array out of a sequence is `reduce(_:_:)` with a closure that copies the accumulator each step — `reduce([:]) { var d = $0; d[k] = v; return d }` or `reduce([]) { $0 + [x] }`. Because the closure returns a new collection per element, the accumulation allocates and copies on every iteration, turning a linear pass into quadratic work. `reduce(into:)` passes the accumulator `inout` and mutates it in place, keeping the pass linear.

**Evidence of violation:** a `reduce(_:_:)` call whose accumulator is a collection (Array, Dictionary, Set, String) and whose closure produces a new copied or concatenated collection per element — the `var copy = $0 … return copy` shape or `$0 + [element]`. PASS: `reduce(into:)` mutating the accumulator in place, or a plain loop appending to a local collection. N/A: the accumulator is a scalar (a sum, a max, a Bool), where `reduce(_:_:)` copies nothing meaningful.

**Incorrect (a fresh dictionary copy per element — O(n²) for a linear job):**

```swift
let checkins = ["oak", "fern", "oak", "moss", "fern", "oak"]

let visitCounts = checkins.reduce([String: Int]()) { counts, trail in
    var updated = counts
    updated[trail, default: 0] += 1
    return updated
}
```

**Correct (in-place mutation keeps the accumulation linear):**

```swift
let checkins = ["oak", "fern", "oak", "moss", "fern", "oak"]

let visitCounts = checkins.reduce(into: [String: Int]()) { counts, trail in
    counts[trail, default: 0] += 1
}
```

Reference: expert Swift reference (2025), “Accumulate collection elements into a single value in a memory-efficient way”.
