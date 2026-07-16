---
title: Count matching elements without an intermediate filter
tags: coll, counting, filter, allocation
---

## Count matching elements without an intermediate filter

The wrong default for counting elements that pass a test is `collection.filter { predicate }.count`: `filter` allocates and populates an intermediate array whose only purpose is to be counted and discarded. `count(where:)` combines the test and the count in a single allocation-free pass over the collection.

**Evidence of violation:** a `.filter { ... }.count` chain where the count is the only use of the filtered result — the filtered array is never bound to a name or reused. PASS: predicate counting uses `count(where:)` (or the trailing-closure form `count { ... }`), or no predicate-count exists in the changed code. N/A: the filtered array is bound and also used for anything besides its count, or the project's toolchain predates `count(where:)` (Swift 6.0) — an older toolchain makes the remedy unavailable, not the code wrong.

**Incorrect (allocates a throwaway array just to read its length):**

```swift
let temperatures = [-5, 10, -2, 20, 25, -1]
let aboveFreezingCount = temperatures.filter { $0 > 0 }.count

print(aboveFreezingCount)
```

**Correct (single pass, no intermediate allocation):**

```swift
let temperatures = [-5, 10, -2, 20, 25, -1]
let aboveFreezingCount = temperatures.count { $0 > 0 }

// Prints `3`
print(aboveFreezingCount)
```
