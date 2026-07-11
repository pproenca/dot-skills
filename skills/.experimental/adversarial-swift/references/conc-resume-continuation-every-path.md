---
title: Resume checked continuations exactly once on every reachable path
tags: conc, continuations, completion-handlers, async-bridging
---

## Resume checked continuations exactly once on every reachable path

The wrong default when bridging a `(Value?, Error?)` completion handler with `withCheckedThrowingContinuation` is handling only the two expected branches — `if let data … else if let error …` — and forgetting the both-`nil` case. A path that never calls `resume` suspends the awaiting task forever with no crash and no log; a path that can resume twice traps at runtime. The source's canonical bridge resumes in a final `else` with a synthesized error precisely so every reachable path resumes exactly once.

**Evidence of violation:** a `withCheckedContinuation` or `withCheckedThrowingContinuation` closure containing any reachable branch that never calls `continuation.resume` (the classic tell is `if let`/`else if let` over an optional pair with no closing `else`), or control flow where two branches can both execute a `resume` (e.g. a resume inside a loop or a resume followed by fall-through into another). PASS: every branch — including the "neither value arrived" fallback — resumes exactly once. N/A: the reviewed code contains no continuation bridging.

**Incorrect (both-nil path never resumes, the task hangs forever):**

```swift
func legacyFetchReport(_ completion: @escaping (Data?, Error?) -> Void) { completion(Data(), nil) }

func fetchReportAsync() async throws -> Data {
    try await withCheckedThrowingContinuation { continuation in
        legacyFetchReport { data, error in
            if let data {
                continuation.resume(returning: data)
            } else if let error {
                continuation.resume(throwing: error)
            }
            // (nil, nil) is reachable: nothing resumes, the await never returns
        }
    }
}
```

**Correct (a final else guarantees exactly one resume per path):**

```swift
enum ReportError: Error { case emptyResponse }
func legacyFetchReport(_ completion: @escaping (Data?, Error?) -> Void) { completion(Data(), nil) }

func fetchReportAsync() async throws -> Data {
    try await withCheckedThrowingContinuation { continuation in
        legacyFetchReport { data, error in
            if let data {
                continuation.resume(returning: data)
            } else if let error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(
                    throwing: ReportError.emptyResponse
                )
            }
        }
    }
}
```

Reference: expert Swift reference (2025), “Bridge async/await and completion handlers”.
