---
title: Upsert dictionary values with the default subscript
tags: coll, dictionaries, upserts, standard-library
---

## Upsert dictionary values with the default subscript

The wrong default for read-modify-write on a dictionary is the hand-rolled dance — `dict[key] = (dict[key] ?? 0) + 1`, or an `if let`/`else` pair where both branches assign `dict[key]`. Both forms hash the key twice, and the nil-coalescing form copies the value out and back instead of mutating it in storage. `subscript(_:default:)` is the standard library's single idiom for exactly this: one lookup, in-place mutation, and the default stated at the point of use.

**Evidence of violation:** a dictionary assignment whose right-hand side reads the same key with `?? <default>` (e.g. `scores[name] = (scores[name] ?? 0) + delta`), or an `if let`/`if var` on `dict[key]` whose both branches end by assigning `dict[key]` and differ only in whether a default seeds the value. PASS: upserts go through `dict[key, default: value]`, or no dictionary read-modify-write exists in the changed code. N/A: the nil and non-nil paths do genuinely different work (not just default-then-combine) — that branching is load-bearing, not an upsert.

**Incorrect (two hash lookups and a duplicated assignment for one upsert):**

```swift
var scores = ["Alice": 10, "Bob": 15]

if let existing = scores["Alice"] {
    scores["Alice"] = existing + 5
} else {
    scores["Alice"] = 5
}
```

**Correct (one lookup, default declared at the point of use):**

```swift
var scores = ["Alice": 10, "Bob": 15]

let aliceScore = scores["Alice", default: 0] // 10
let charlieScore = scores["Charlie", default: 0] // 0

scores["Alice", default: 0] += 5
```
