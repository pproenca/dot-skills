---
title: Take conditionally used parameters as autoclosures to defer their evaluation
tags: api, autoclosure, lazy-evaluation, logging
---

## Take conditionally used parameters as autoclosures to defer their evaluation

The wrong default for log/assert/validation-style helpers is an eagerly evaluated parameter — `message: String` — whose only use sits inside a condition controlled by another parameter or ambient state, so every call site pays the full construction cost (string interpolation, formatting, computation) even when the guarded branch never runs. Declaring the parameter `@autoclosure () -> String` keeps call-site syntax identical while evaluating the expression only when the branch executes.

**Evidence of violation:** a function where a parameter's only use sites are inside a conditional branch gated by another parameter or ambient state (a log level, a debug flag), and the parameter is not declared `@autoclosure`. PASS: such parameters are autoclosures, or the parameter is read unconditionally. N/A: every visible call site passes a cheap literal with no interpolation or computation, or no conditionally used parameter occurs in the target.

**Incorrect (the expensive interpolation runs even when the level is filtered out):**

```swift
enum LogLevel: Comparable {
    case debug, info, warning, error
}

var currentLogLevel: LogLevel = .info

func logMessage(
    level: LogLevel,
    message: String
) {
    if level >= currentLogLevel {
        print(message)
    }
}

func expensiveStringComputation() -> String {
    // Simulate an expensive operation
    return "Expensive Computed String"
}

// The interpolation — and the expensive call — evaluate on every invocation,
// including when .debug is below the current level and nothing prints
logMessage(
    level: .debug,
    message: "Debug: \(expensiveStringComputation())"
)
```

**Correct (the autoclosure defers evaluation until the branch actually runs):**

```swift
enum LogLevel: Comparable {
    case debug, info, warning, error
}

var currentLogLevel: LogLevel = .info

func logMessage(
    level: LogLevel,
    message: @autoclosure () -> String
) {
    if level >= currentLogLevel {
        print(message())
    }
}

func expensiveStringComputation() -> String {
    // Simulate an expensive operation
    return "Expensive Computed String"
}

currentLogLevel = .debug
logMessage(
    level: .debug,
    message: "Debug: \(expensiveStringComputation())"
)
```
