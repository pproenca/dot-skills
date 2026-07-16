---
title: Pair elements with their real indices via zip, never the enumerated offset
tags: flow, collections, indices, slices
---

## Pair elements with their real indices via zip, never the enumerated offset

The wrong default for "items and indices" is `for (i, x) in collection.enumerated()` with `i` used as a subscript. `enumerated()` yields a zero-based counter, not an index — on a slice (`dropFirst()`, `prefix`, a subrange) or any non-zero-based collection the counter and the indices diverge, producing an out-of-bounds trap or silent off-by-N element corruption with no compiler diagnostic. `zip(collection.indices, collection)` pairs each element with an index that is valid by construction.

**Evidence of violation:** a `for (i, element) in c.enumerated()` loop where `i` subscripts `c` or a collection derived from it, and `c` is not provably a whole zero-based `Array` in the same scope — any `SubSequence`, slice, or generic `Collection` value counts as a violation. PASS: the offset is used only for display or counting, or subscripting goes through `zip(c.indices, c)` (or equivalent index-based iteration). N/A: no loop in the target pairs positions with elements.

**Incorrect (the counter starts at 0 but the slice's indices start at 1 — this traps):**

```swift
var ingredients = ["potatoes", "cheese", "cream"]

// Array<String>.SubSequence — its indices are 1 and 2, not 0 and 1
var doubleIngredients = ingredients.dropFirst()

for (i, ingredient) in doubleIngredients.enumerated() {
    // First iteration subscripts index 0, which the slice does not contain:
    // runtime trap (or, on other slice shapes, writes to the wrong element)
    doubleIngredients[i] = "\(ingredient) x 2"
}
```

**Correct (zip pairs each element with an index that is valid for the slice):**

```swift
// Array<String>
var ingredients = ["potatoes", "cheese", "cream"]

// Array<String>.SubSequence
var doubleIngredients = ingredients.dropFirst()

for (i, ingredient) in zip(
    doubleIngredients.indices, doubleIngredients
) {
    // Correctly use the actual indices of the subsequence
    doubleIngredients[i] = "\(ingredient) x 2"
}
```

The counter form is fine when it is only a display ordinal:

```swift
var ingredients = ["potatoes", "cheese", "cream"]

for (i, ingredient) in ingredients.enumerated() {
    // The counter helps us display the sequence number, not the index
    print("ingredient number \(i + 1) is \(ingredient)")
}
```
