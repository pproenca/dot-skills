---
title: "Swift/ObjC Bridge Type Mismatch Crashes at Runtime"
impact: LOW-MEDIUM
impactDescription: "unexpected type cast crash when ObjC returns different type than expected"
tags: objc, bridge, type-cast, nsarray, crash
---

## Swift/ObjC Bridge Type Mismatch Crashes at Runtime

Objective-C collections are untyped -- an `NSArray` may contain `NSString`, `NSNumber`, and `NSNull` in the same array. Bridging to a typed Swift `Array<String>` with `as!` crashes at runtime if any element does not match. The compiler cannot catch this because the ObjC type system has no generics.

**Incorrect (force-casts untyped NSArray to typed Swift array, crashing on mismatch):**

```swift
import Foundation

class AnalyticsEventParser {
    func parseEventNames(from objcArray: NSArray) -> [String] {
        // ObjC array may contain NSNumber or NSNull — force-cast crashes
        let names = objcArray as! [String]
        return names
    }

    func parseEventValues(from objcDict: NSDictionary) -> [String: Int] {
        // Mixed value types in NSDictionary crash on bridge
        let values = objcDict as! [String: Int]
        return values
    }
}
```

**Proof Test (exposes crash when NSArray contains mixed types):**

```swift
import XCTest

final class AnalyticsEventParserBridgeTests: XCTestCase {
    func testParseEventNamesHandlesMixedTypes() {
        let parser = AnalyticsEventParser()

        // ObjC SDK returns mixed-type array
        let mixedArray: NSArray = [
            "screen_view",
            NSNumber(value: 42),
            NSNull(),
            "button_tap"
        ]

        // Force-cast to [String] crashes on NSNumber element
        let names = parser.parseEventNames(from: mixedArray)
        XCTAssertEqual(names, ["screen_view", "button_tap"])
    }

    func testParseEventValuesHandlesMixedValueTypes() {
        let parser = AnalyticsEventParser()

        let mixedDict: NSDictionary = [
            "clicks": NSNumber(value: 5),
            "label": "home",  // String instead of Int
            "views": NSNumber(value: 100)
        ]

        let values = parser.parseEventValues(from: mixedDict)
        XCTAssertEqual(values["clicks"], 5)
    }
}
```

**Correct (uses compactMap with conditional casts to safely filter matching types):**

```swift
import Foundation

class AnalyticsEventParser {
    func parseEventNames(from objcArray: NSArray) -> [String] {
        // Conditional cast filters non-String elements safely
        return objcArray.compactMap { $0 as? String }
    }

    func parseEventValues(from objcDict: NSDictionary) -> [String: Int] {
        var result: [String: Int] = [:]
        for (key, value) in objcDict {
            // Only include entries where both key and value match expected types
            if let key = key as? String, let intValue = value as? Int {
                result[key] = intValue
            }
        }
        return result
    }
}
```
