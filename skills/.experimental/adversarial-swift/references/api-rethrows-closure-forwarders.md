---
title: Declare rethrows on functions that only forward closure errors
tags: api, error-handling, rethrows, higher-order-functions
---

## Declare rethrows on functions that only forward closure errors

The wrong default is declaring a higher-order function unconditionally `throws` when its only throw source is invoking its `throws` closure parameter. That forces `try` and `do-catch` ceremony on every caller — including the ones passing non-throwing closures that can never fail. `rethrows` makes the function throwing only when its argument actually throws, so non-throwing call sites stay clean while throwing ones still propagate.

**Evidence of violation:** a function with a `(...) throws -> ...` closure parameter, declared plain `throws`, whose body throws only via calls to that parameter — no independent `throw` statement or call to another throwing function. PASS when it is declared `rethrows`, or when it uses typed throws to propagate the closure's error type (`throws(E)` where the parameter is `throws(E)`, Swift 6.0+). N/A when the body has its own independent throw source — plain `throws` is then correct.

**Incorrect (non-throwing callers pay do-catch ceremony for errors that cannot happen):**

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

// Caller with a non-throwing closure still needs try:
let doubled = try transform([1, 2, 3]) { $0 * 2 }
```

**Correct (throwing behavior adapts to the closure argument):**

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

// Non-throwing closure, no try needed:
let doubled = transform([1, 2, 3]) { $0 * 2 }
```

Reference: *Swift Gems* (Natalia Panferova, Nil Coalescing, updated Nov 2025), “Optimize error handling in higher-order functions with rethrows”
