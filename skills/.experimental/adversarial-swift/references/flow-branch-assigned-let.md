---
title: Assign branch-determined constants to an uninitialized let, not a placeholder var
tags: flow, definite-initialization, constants, control-flow
---

## Assign branch-determined constants to an uninitialized let, not a placeholder var

The wrong default when a value depends on conditions is `var message = ""` followed by reassignment inside the branches. The placeholder disables the compiler's definite-initialization check — a branch that forgets to assign silently ships the empty string, and a `switch` loses exhaustiveness enforcement for the assignment. Declaring an uninitialized `let` and assigning it in every branch turns the same omission into a compile error.

**Evidence of violation:** a `var` initialized to a placeholder or dummy value (`""`, `0`, an empty collection) that is unconditionally overwritten in every branch of a following `if`/`switch` and never mutated afterward. PASS: the value is declared as an uninitialized `let` assigned in every branch, or the initial value is a genuine default some path keeps. N/A: some branch legitimately keeps the initial value, or the variable mutates later in its scope.

**Incorrect (placeholder var — a forgotten branch ships "" with no diagnostic):**

```swift
func weatherNotification(for temperature: Int) -> String {
    var message = ""

    if temperature > 30 {
        message = "It's hot outside."
    } else if temperature < 0 {
        message = "Freezing temperatures!"
    } else {
        message = "Mild weather."
    }

    let detailedMessage = message + " Take necessary precautions."
    return detailedMessage
}
```

**Correct (uninitialized let — the compiler proves every path assigns exactly once):**

```swift
func weatherNotification(for temperature: Int) -> String {
    let message: String

    if temperature > 30 {
        message = "It's hot outside."
    } else if temperature < 0 {
        message = "Freezing temperatures!"
    } else {
        message = "Mild weather."
    }

    let detailedMessage = message + " Take necessary precautions."
    return detailedMessage
}
```
