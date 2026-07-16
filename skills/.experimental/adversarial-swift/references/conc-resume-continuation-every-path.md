---
title: Resume checked continuations exactly once on every reachable path
tags: conc, continuations, completion-handlers, async-bridging
---

## Resume checked continuations exactly once on every reachable path

The wrong default when bridging a `(Data?, Error?)` completion handler with `withCheckedThrowingContinuation` is mirroring only the two expected branches — `if let data … else if let error …` — and leaving the both-`nil` path without a `resume`. A continuation that never resumes suspends the awaiting task forever: no crash, no thrown error, no leak trace, and only the checked variants even log the loss. A path that can resume twice traps at runtime instead.

**Evidence of violation:** a `withCheckedContinuation` or `withCheckedThrowingContinuation` (or unsafe variant) closure containing any reachable path that exits without calling `continuation.resume` — the canonical tell is `if let`/`else if let` over an optional pair with no terminal `else`, or a `switch` case that returns early — or control flow where two branches can both execute a `resume`. Paths the callback's API contract claims are unreachable still fail unless the contract is enforced in code; the compiler cannot see contracts. PASS: every reachable path, including the "neither value arrived" fallback, resumes exactly once. N/A: the target contains no continuation bridging.

**Incorrect (the both-nil callback path never resumes — the awaiting task hangs forever):**

```swift
import Foundation

func fetchData(completion: @escaping (Data?, Error?) -> Void) {
    // Simulating a network request
    DispatchQueue.global(qos: .background).async {
        let data = "Sample data".data(using: .utf8)
        completion(data, nil)
    }
}

func fetchDataAsync() async throws -> Data {
    try await withCheckedThrowingContinuation { continuation in
        fetchData { data, error in
            if let data = data {
                continuation.resume(returning: data)
            } else if let error = error {
                continuation.resume(throwing: error)
            }
            // (nil, nil) is reachable: nothing resumes, the await never returns
        }
    }
}
```

**Correct (a terminal else guarantees exactly one resume per path):**

```swift
import Foundation

func fetchData(completion: @escaping (Data?, Error?) -> Void) {
    // Simulating a network request
    DispatchQueue.global(qos: .background).async {
        let data = "Sample data".data(using: .utf8)
        completion(data, nil)
    }
}

func fetchDataAsync() async throws -> Data {
    try await withCheckedThrowingContinuation { continuation in
        fetchData { data, error in
            if let data = data {
                continuation.resume(returning: data)
            } else if let error = error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(
                    throwing: NSError(
                        domain: "DataError",
                        code: -1, userInfo: nil
                    )
                )
            }
        }
    }
}
```
