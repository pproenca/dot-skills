---
title: "Use Inline Snapshots for Non-Image Assertions"
impact: LOW-MEDIUM
impactDescription: "eliminates separate reference files for text/JSON snapshots"
tags: snap, inline, text, json, assertInlineSnapshot
---

## Use Inline Snapshots for Non-Image Assertions

File-based snapshots for text and JSON outputs scatter reference data across `__Snapshots__` directories, forcing developers to open a separate file to understand what the test expects. Inline snapshots embed the expected value directly in the test source, making assertions reviewable in a single glance and diffs visible in standard code review tools.

**Incorrect (expected JSON lives in a separate reference file):**

```swift
import Testing
import SnapshotTesting
@testable import Analytics

@Suite struct EventSerializerTests {
    @Test func serializesAddToCartEvent() {
        let event = AnalyticsEvent.addToCart(itemId: "SKU-1042", price: 29.99)
        let serializer = EventSerializer()

        let json = serializer.toJSON(event)

        // Expected output hidden in __Snapshots__/EventSerializerTests/serializesAddToCartEvent.1.txt
        assertSnapshot(of: json, as: .lines)
    }
}
```

**Correct (expected value visible inline, no separate file needed):**

```swift
import Testing
import InlineSnapshotTesting
@testable import Analytics

@Suite struct EventSerializerTests {
    @Test func serializesAddToCartEvent() {
        let event = AnalyticsEvent.addToCart(itemId: "SKU-1042", price: 29.99)
        let serializer = EventSerializer()

        let json = serializer.toJSON(event)

        // Expected value auto-populated on first run, reviewed inline in code review
        assertInlineSnapshot(of: json, as: .lines) {
            """
            {
              "event": "add_to_cart",
              "item_id": "SKU-1042",
              "price": 29.99
            }
            """
        }
    }
}
```
