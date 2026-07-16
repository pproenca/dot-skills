---
title: Validate untrusted bytes before creating a String
tags: flow, strings, unicode, input-validation
---

## Validate untrusted bytes before creating a String

The wrong default for decoding bytes from a network response, file, user input, or C interop is `String(decoding:as:)`, which silently replaces every invalid sequence with U+FFFD replacement characters. Silent repair lets malformed text enter the system as if it were valid — corrupted identifiers, keys, and user content propagate downstream with no error at the boundary where the corruption happened. `String(validating:as:)` returns `nil` for invalid input, forcing the boundary to decide.

**Evidence of violation:** `String(decoding:as:)` (or a force-unwrapped `String(data:encoding:)`) applied to bytes originating from an untrusted or external source — network, file, user input, a C API — with no prior validation. PASS: the bytes are compile-time constants or provably produced by the program itself (such as re-decoding its own `utf8` view), or a comment at the call site states that lossy repair is acceptable for a display-only context. N/A: the target creates no strings from byte sequences, or the toolchain predates Swift 6.0 (`String(validating:as:)` unavailable — flag the decode in Out of scope instead).

**Incorrect (silent repair — corrupted network text flows on as if valid):**

```swift
import Foundation

/// Decodes a device name from a payload received off the wire.
func deviceName(from payload: Data) -> String {
    // Invalid sequences are silently repaired to U+FFFD and flow on
    // downstream as if the payload had been well-formed
    String(decoding: payload, as: UTF8.self)
}
```

**Correct (validation returns nil at the boundary, so the failure is explicit):**

```swift
let validUTF8: [UInt8] = [67, 97, 102, 195, 169]
let valid = String(validating: validUTF8, as: UTF8.self)

// Prints `Café`
print(valid ?? "nil")

// Ends with a dangling surrogate
let invalidUTF16: [UInt16] = [0x41, 0x42, 0xd801]
let invalid = String(validating: invalidUTF16, as: UTF16.self)

// Prints `nil`
print(invalid ?? "nil")
```
