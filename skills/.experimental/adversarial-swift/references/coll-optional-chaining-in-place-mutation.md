---
title: Mutate nested dictionary values in place with optional chaining
tags: coll, dictionaries, optional-chaining, copy-on-write
---

## Mutate nested dictionary values in place with optional chaining

The wrong default for editing a value stored in a dictionary is unwrap-copy-mutate-reassign: bind `dict[key]` with `if var`, mutate the binding, then write it back. The copy-out/write-back dance forces a copy-on-write clone of the value (O(n) for an array value), performs two hash lookups, and spends four lines where one works. `dict[key]?[0] = newValue` mutates the stored value in place through optional chaining, and is a silent no-op when the key is absent — the intended semantics for an edit of existing data.

**Evidence of violation:** an `if var`/`guard var` binding of `dict[key]` whose body mutates the binding and ends with `dict[key] = binding`, with no other behavior on the else path. PASS: nested edits use optional chaining on the subscript (`dict[key]?.mutatingCall()` / `dict[key]?[index] = value`), or no nested dictionary-value mutation exists in the changed code. N/A: the else branch inserts a fresh value (that is `subscript(_:default:)`'s job, judged by coll-dictionary-default-subscript) or the copied binding is deliberately kept for comparison against the original.

**Incorrect (CoW copy of the array, two lookups, write-back ceremony):**

```swift
var bookReviews = [
    "ISBN-001": [5, 4, 5, 3],
    "ISBN-002": [4, 5, 4]
]

if var reviews = bookReviews["ISBN-001"] {
    reviews[0] = 3
    bookReviews["ISBN-001"] = reviews
}
```

**Correct (in-place mutation, absent key is a no-op):**

```swift
var bookReviews = [
    "ISBN-001": [5, 4, 5, 3],
    "ISBN-002": [4, 5, 4]
]

bookReviews["ISBN-001"]?[0] = 3

bookReviews["ISBN-002"]?[0] += 1
```
