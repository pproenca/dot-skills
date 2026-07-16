---
title: Accumulate collections with in-place reduce
tags: coll, reduce, accumulation, allocation
---

## Accumulate collections with in-place reduce

The wrong default for accumulating into an Array, Dictionary, Set, or String is `reduce(_:_:)`, whose closure must return a fresh accumulator — so every element copies the entire collection built so far, turning a linear accumulation into O(n²) copies. `reduce(into:)` passes the accumulator `inout` and mutates one instance in place; for dictionaries it composes with `subscript(_:default:)` into the canonical single-pass frequency-count idiom.

**Evidence of violation:** a `reduce(` call (not `reduce(into:`) whose initial value is a collection literal or constructor (`[]`, `[:]`, `""`, `[Int: Int]()`) or whose closure returns `accumulator + element` or a copied-and-modified collection. PASS: collection accumulation uses `reduce(into:)` (or an equivalent single-pass API such as `Dictionary(grouping:by:)`), or no collection-typed reduce exists in the changed code. N/A: the accumulator is a scalar (Int, Double, Bool) — copying a scalar is free, and plain `reduce(_:_:)` is the right form there.

**Incorrect (copies the whole dictionary once per element):**

```swift
let numbers = [1, 2, 1, 3, 2, 1, 4, 2]

let frequency = numbers.reduce([Int: Int]()) { counts, number in
    var copy = counts
    copy[number, default: 0] += 1
    return copy
}

print(frequency)
```

**Correct (one accumulator mutated in place, single pass):**

```swift
let numbers = [1, 2, 1, 3, 2, 1, 4, 2]

let frequency = numbers.reduce(into: [:]) { (counts, number) in
    counts[number, default: 0] += 1
}

// Prints `[1: 3, 2: 3, 3: 1, 4: 1]`
print(frequency)
```
