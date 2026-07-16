---
title: Convert Result with try get() instead of a manual switch
tags: err, result, error-handling
---

## Convert Result with try get() instead of a manual switch

The wrong default when unpacking a `Result` inside a throwing context is a `switch` whose branches only return the success value and throw the failure — four lines of ceremony re-implementing `Result.get()`. Each hand-rolled unpack is one more place to accidentally swallow or transform the error inconsistently, and it buries the one interesting line (what happens to the value) under mechanical plumbing.

**Evidence of violation:** a `switch` or `if case` over a `Result` value inside a `throws` function where the success branch only yields the associated value and the failure branch only throws the associated error, with no additional per-branch logic. PASS: `try result.get()` performs the conversion, or the branches carry extra work (logging, error mapping, a fallback value) that `get()` cannot express. N/A: the target unpacks no `Result` values inside throwing contexts.

**Incorrect (manual switch re-implements get()):**

```swift
func fetchData() -> Result<String, Error> {
    .success("Data loaded")
}

func processData() throws {
    let result = fetchData()
    switch result {
    case .success(let data):
        print(data)
    case .failure(let error):
        throw error
    }
}
```

**Correct (try get() converts the Result in one line):**

```swift
func fetchData() -> Result<String, Error> {
    .success("Data loaded")
}

func processData() throws {
    let result = fetchData()
    let data = try result.get()
    print(data)
}
```
