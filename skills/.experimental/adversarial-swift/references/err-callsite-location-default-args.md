---
title: Capture call-site location through default file and line arguments
tags: err, logging, source-location, diagnostics
---

## Capture call-site location through default file and line arguments

The wrong default when writing a logging, assertion, or error-reporting helper is referencing `#file`, `#line`, and `#function` inside the helper's body — where the literals expand to the helper's own location, so every log line reports the wrapper file instead of the caller that failed. Diagnostics that all point at the logger are useless for pinpointing failures. The compiler substitutes these literals at the call site only when they appear as default parameter values, so the fix is mechanical and lossless.

**Evidence of violation:** a diagnostics helper (a function whose purpose is logging, assertion wrapping, or error reporting — it takes a message-like parameter) that references `#file`, `#line`, `#function`, or `#column` in its body rather than as default parameter values, or that prints location information without forwarding call-site defaults. PASS: every location literal in a diagnostics helper appears as a default parameter value forwarded from the caller. N/A: the helper reports no source location at all (no location literal appears anywhere in it), or the target contains no diagnostics helpers.

**Incorrect (literals in the body expand to the helper's own location):**

```swift
func logError(_ message: String) {
    // #file and #line expand HERE — every log points at the logger itself
    print("""
    Error: \(message), file: \(#file), \
    line: \(#line), function: \(#function)
    """)
}

func processUserInput(_ input: String) {
    guard input != "error" else {
        logError("Invalid user input")
        return
    }
    print("User input processed successfully: \(input)")
}

processUserInput("error")
```

**Correct (default arguments capture the caller's location):**

```swift
func logError(
    _ message: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
) {
    print("""
    Error: \(message), file: \(file), \
    line: \(line), function: \(function)
    """)
}

func processUserInput(_ input: String) {
    guard input != "error" else {
        logError("Invalid user input")
        return
    }
    print("User input processed successfully: \(input)")
}

// Prints `User input processed successfully: hello`
processUserInput("hello")

/* Prints `Error: Invalid user input, file:
 .../main.swift, line: 19, function: processUserInput(_:)`
*/
processUserInput("error")
```
