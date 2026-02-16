---
title: "Non-Exhaustive Switch Crashes on Unknown Enum Case"
impact: LOW-MEDIUM
impactDescription: "crash when server sends new enum value not in client code"
tags: mut, enum, switch, unknown-case, api-evolution
---

## Non-Exhaustive Switch Crashes on Unknown Enum Case

Switching on an enum decoded from an API response without a `default` case crashes when the server adds new values. The client's switch statement is exhaustive at compile time but not at runtime — the raw value initializer produces a case the switch doesn't handle.

**Incorrect (switch without default case crashes on unknown server value):**

```swift
import Foundation

enum PaymentStatus: String, Decodable {
    case pending
    case completed
    case failed
    case refunded
}

class PaymentStatusMapper {
    func displayText(for status: PaymentStatus) -> String {
        switch status {
        case .pending:   return "Processing your payment..."
        case .completed: return "Payment successful"
        case .failed:    return "Payment failed"
        case .refunded:  return "Refund issued"
        // No default — future cases crash at runtime
        }
    }

    func mapFromAPI(rawValue: String) -> String {
        // Force-creates enum — crashes on unknown values
        let status = PaymentStatus(rawValue: rawValue)!
        return displayText(for: status)
    }
}
```

**Proof Test (exposes the crash when server sends a new status value):**

```swift
import XCTest

final class PaymentStatusMapperTests: XCTestCase {
    func testUnknownStatusDoesNotCrash() {
        let mapper = PaymentStatusMapper()

        // Server adds "disputed" status in new API version
        let result = mapper.mapFromAPI(rawValue: "disputed")

        // Force-unwrap on unknown rawValue crashes
        XCTAssertFalse(result.isEmpty,
            "Unknown status should produce fallback text, not crash")
    }

    func testNullStatusDoesNotCrash() {
        let mapper = PaymentStatusMapper()

        let result = mapper.mapFromAPI(rawValue: "")
        XCTAssertFalse(result.isEmpty,
            "Empty status should produce fallback text, not crash")
    }
}
```

**Correct (handles unknown raw values and uses @unknown default for future cases):**

```swift
import Foundation

enum PaymentStatus: String, Decodable {
    case pending
    case completed
    case failed
    case refunded
    case unknown
}

class PaymentStatusMapper {
    func displayText(for status: PaymentStatus) -> String {
        switch status {
        case .pending:   return "Processing your payment..."
        case .completed: return "Payment successful"
        case .failed:    return "Payment failed"
        case .refunded:  return "Refund issued"
        case .unknown:   return "Status unavailable"
        @unknown default: return "Status unavailable"  // future-proof
        }
    }

    func mapFromAPI(rawValue: String) -> String {
        let status = PaymentStatus(rawValue: rawValue) ?? .unknown
        return displayText(for: status)
    }
}
```
