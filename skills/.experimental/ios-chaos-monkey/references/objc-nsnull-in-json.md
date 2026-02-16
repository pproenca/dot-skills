---
title: "NSNull in Decoded JSON Collection Crashes on Access"
impact: LOW-MEDIUM
impactDescription: "unrecognized selector sent to NSNull, crash on property access"
tags: objc, nsnull, json, decoding, crash
---

## NSNull in Decoded JSON Collection Crashes on Access

JSON `null` values decoded into `NSDictionary` or `NSArray` via `JSONSerialization` become `NSNull` instances, not Swift `nil`. Casting `NSNull` to `String` or calling methods on it crashes with `unrecognized selector sent to instance`. This is invisible at compile time.

**Incorrect (treats JSON values as String without checking for NSNull):**

```swift
import Foundation

class LegacyAPIParser {
    func parseUsers(from jsonData: Data) -> [(name: String, bio: String)] {
        guard let array = try? JSONSerialization.jsonObject(
            with: jsonData) as? [[String: Any]] else {
            return []
        }

        return array.map { dict in
            // NSNull crashes when cast with as! or accessed as String
            let name = dict["name"] as! String
            let bio = dict["bio"] as! String  // NSNull if JSON value is null
            return (name: name, bio: bio)
        }
    }
}
```

**Proof Test (exposes crash when JSON contains null values):**

```swift
import XCTest

final class LegacyAPIParserNSNullTests: XCTestCase {
    func testParseUsersHandlesNullBio() throws {
        let parser = LegacyAPIParser()

        // Server sends null for bio field
        let json = """
        [
            {"name": "Alice", "bio": null},
            {"name": "Bob", "bio": "Engineer"}
        ]
        """.data(using: .utf8)!

        // Force-cast of NSNull to String crashes
        let users = parser.parseUsers(from: json)
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].name, "Alice")
    }

    func testParseUsersHandlesMissingName() throws {
        let parser = LegacyAPIParser()

        let json = """
        [{"bio": "Designer"}]
        """.data(using: .utf8)!

        // Missing key returns nil, force-cast crashes
        let users = parser.parseUsers(from: json)
        XCTAssertEqual(users.count, 0)
    }
}
```

**Correct (filters NSNull and uses conditional casts for safe access):**

```swift
import Foundation

class LegacyAPIParser {
    func parseUsers(from jsonData: Data) -> [(name: String, bio: String)] {
        guard let array = try? JSONSerialization.jsonObject(
            with: jsonData) as? [[String: Any]] else {
            return []
        }

        return array.compactMap { dict in
            // Conditional cast returns nil for NSNull — no crash
            guard let name = dict["name"] as? String else { return nil }
            let bio = (dict["bio"] as? String) ?? ""  // NSNull becomes ""
            return (name: name, bio: bio)
        }
    }
}
```
