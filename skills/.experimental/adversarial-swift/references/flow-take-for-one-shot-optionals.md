---
title: Consume one-shot optionals with take(), not read-then-nil
tags: flow, optionals, consume-semantics, state
---

## Consume one-shot optionals with take(), not read-then-nil

The wrong default for consuming a single-use optional (a token, a pending continuation, a buffered value) is the two-step dance — read it into a binding, then set the property to `nil`. The two statements can drift apart under later edits, leaving a window where the stale value is read again or the reset is dropped from one path. `take()` unwraps and clears in one mutating operation, making single-use semantics explicit and structurally closing that window. The consequence is intent and robustness, not a crash — the two-step form is equivalent only while nothing slips between its halves.

**Evidence of violation:** an optional `var` read into a binding and set to `nil` within the same consume sequence (adjacent statements, or the read and the reset spread across one teardown path). PASS: consume sites use `take()` (or the two steps are provably a non-consume pattern — the value is intentionally kept). N/A: the toolchain's standard library predates `Optional.take()`, or statements between the read and the `nil` deliberately reuse the optional.

**Incorrect (read and reset are separate statements that later edits can split):**

```swift
var token: String? = "abc123"

if let value = token {
    print("Using token:", value)
    token = nil
}
```

**Correct (one operation extracts the value and clears the storage):**

```swift
var token: String? = "abc123"

if let value = token.take() {
    print("Using token:", value)
}

// Prints `Token is now: nil`
print("Token is now: \(token ?? "nil")")
```
