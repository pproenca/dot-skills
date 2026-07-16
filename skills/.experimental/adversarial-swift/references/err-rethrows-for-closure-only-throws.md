---
title: Declare rethrows when the only throw source is a closure parameter
tags: err, rethrows, higher-order-functions
---

## Declare rethrows when the only throw source is a closure parameter

The wrong default for a higher-order function that accepts a throwing closure is declaring the function itself `throws`. That signature is a lie for non-throwing closures: every call site that passes a plain function must now spell `try` and handle an error that can never occur. `rethrows` makes the function throwing exactly when the supplied closure throws, so non-throwing call sites stay clean and the compiler enforces the distinction.

**Evidence of violation:** a function declared `throws` that takes a throwing closure parameter, whose body contains no `throw` statement and whose every `try` applies only to calls of that closure parameter. PASS: the function is declared `rethrows`, or its body has an independent throw source (its own `throw`, or `try` on something other than the closure parameter) that justifies plain `throws`. N/A: the target declares no higher-order functions with throwing closure parameters, or the design uses typed throws to propagate the closure's error type generically (`throws(E)` paired with a `(T) throws(E) -> U` parameter).

**Incorrect (plain throws forces try onto call sites whose closure never throws):**

```swift
func transform<T>(
    _ items: [T],
    using transformFunction: (T) throws -> T
) throws -> [T] {
    var transformedItems = [T]()
    for item in items {
        transformedItems.append(try transformFunction(item))
    }
    return transformedItems
}

func square(_ number: Int) -> Int {
    return number * number
}

let numbers = [1, 2, 3, 4, 5]

// square never throws, yet the call site must handle an impossible error
let squaredNumbers = try transform(numbers, using: square)
print(squaredNumbers)
```

**Correct (rethrows keeps non-throwing call sites clean):**

```swift
func transform<T>(
    _ items: [T],
    using transformFunction: (T) throws -> T
) rethrows -> [T] {
    var transformedItems = [T]()
    for item in items {
        transformedItems.append(try transformFunction(item))
    }
    return transformedItems
}

func square(_ number: Int) -> Int {
    return number * number
}

let numbers = [1, 2, 3, 4, 5]
let squaredNumbers = transform(numbers, using: square)
print(squaredNumbers)
```
