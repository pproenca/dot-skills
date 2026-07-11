---
title: Decode untrusted bytes with validating String initializers
tags: flow, strings, unicode, input-validation, swift-six
---

## Decode untrusted bytes with validating String initializers

The wrong default for turning external bytes into text is `String(decoding: data, as: UTF8.self)`, which never fails — it silently replaces every invalid sequence with U+FFFD replacement characters, letting malformed text flow onward as if it were valid. For bytes from the network, files, or C APIs, that silent repair hides corruption and truncation at the one boundary where it is cheap to catch. Swift 6.0's `String(validating:as:)` returns `nil` on any invalid sequence, forcing the corruption to be handled where it entered.

**Evidence of violation:** `String(decoding:as:)` (or another silently repairing initializer) applied to bytes originating from the network, file reads, or C interop. PASS: `String(validating:as:)` with the `nil` case handled, or `String(data:encoding:)` with its optional result handled. N/A: the toolchain is older than Swift 6.0 (where the validating initializers were introduced), or the bytes are compile-time-known internal literals where invalid input is unrepresentable.

**Incorrect (invalid bytes are silently repaired into replacement characters):**

```swift
func deviceName(from packet: Data) -> String {
    String(decoding: packet, as: UTF8.self)
    // truncated multi-byte sequences arrive as "Caf\u{FFFD}" and keep flowing
}
```

**Correct (corruption surfaces as nil at the boundary and is handled there):**

```swift
enum PairingError: Error { case malformedDeviceName }

func deviceName(from packet: Data) throws -> String {
    guard let name = String(validating: packet, as: UTF8.self) else {
        throw PairingError.malformedDeviceName
    }
    return name
}
```

Reference: expert Swift reference (2025), “Validate encoded input before creating a string”.
