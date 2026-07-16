---
title: Declare Never as the return type of functions that cannot return
tags: api, never, control-flow, unreachable-code
---

## Declare Never as the return type of functions that cannot return

The wrong default for a helper that unconditionally traps — an unreachable-code assertion, an abort wrapper — is declaring it with a normal (or `Void`) return type, which forces callers on "impossible" branches to fabricate placeholder return values to satisfy the compiler. A fabricated placeholder is live code: if the impossible assumption ever breaks, it flows into real execution instead of stopping the program. Declaring `-> Never` tells the compiler control flow ends there, so trap-calling branches type-check with no dummy values at all.

**Evidence of violation:** a function whose every path ends in `fatalError`/`preconditionFailure`/`exit` yet declares a non-`Never` return type, or a branch returning a fabricated placeholder value (`return ""`, `return 0`) where surrounding code or comments mark the branch unreachable. PASS: trap-only helpers return `Never` and unreachable branches contain only the trap call. N/A: some path of the function genuinely returns a value.

**Incorrect (the Void helper forces a fabricated placeholder return after it):**

```swift
func assertUnreachableCode(
    file: String = #file,
    line: Int = #line,
    function: String = #function
) {
    print("""
    Fatal error: Unreachable code reached \
    in \(file) at line \(line), function \(function)
    """)

    fatalError("Unreachable code reached")
}

enum UserCommand {
    case start, stop, pause, resume, unknown
}

func processCommand(_ command: UserCommand) -> String {
    switch command {
    case .start: return "Started"
    case .stop: return "Stopped"
    case .pause: return "Paused"
    case .resume: return "Resumed"
    case .unknown:
        // This case should logically never occur
        assertUnreachableCode()
        return "" // placeholder the compiler demands — live if the assumption breaks
    }
}
```

**Correct (Never ends control flow — no placeholder value exists):**

```swift
func assertUnreachableCode(
    file: String = #file,
    line: Int = #line,
    function: String = #function
) -> Never {
    print("""
    Fatal error: Unreachable code reached \
    in \(file) at line \(line), function \(function)
    """)

    fatalError("Unreachable code reached")
}

enum UserCommand {
    case start, stop, pause, resume, unknown
}

func processCommand(_ command: UserCommand) -> String {
    switch command {
    case .start: return "Started"
    case .stop: return "Stopped"
    case .pause: return "Paused"
    case .resume: return "Resumed"
    case .unknown:
        // This case should logically never occur
        assertUnreachableCode()
    }
}
```
