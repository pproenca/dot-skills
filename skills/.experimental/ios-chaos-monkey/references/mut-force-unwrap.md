---
title: "Force Unwrapping Optional in Production Crashes on Nil"
impact: MEDIUM
impactDescription: "fatal error: Unexpectedly found nil, 100% crash when assumption fails"
tags: mut, optional, force-unwrap, nil, crash
---

## Force Unwrapping Optional in Production Crashes on Nil

Force-unwrap (`!`) assumes a value is always present. When server responses change format, optional fields are removed, or edge cases emerge in production, the assumption fails with a fatal error. The crash occurs at the unwrap site with no recovery path.

**Incorrect (force-unwraps API response fields that can be nil):**

```swift
import Foundation

struct UserProfile {
    let name: String
    let email: String
    let avatarURL: URL?
}

class UserProfileMapper {
    func map(from json: [String: Any]) -> UserProfile {
        // Server can omit fields or send null — force-unwrap crashes
        let name = json["name"] as! String
        let email = json["email"] as! String
        let avatarString = json["avatar_url"] as! String
        let avatarURL = URL(string: avatarString)!

        return UserProfile(
            name: name,
            email: email,
            avatarURL: avatarURL
        )
    }
}
```

**Proof Test (exposes the crash when API response contains nil values):**

```swift
import XCTest

final class UserProfileMapperTests: XCTestCase {
    func testMapHandlesMissingFields() {
        let mapper = UserProfileMapper()

        // Server sends partial response — name is missing
        let incompleteJSON: [String: Any] = [
            "email": "alice@example.com"
        ]

        // Force-unwrap on missing "name" crashes
        let profile = mapper.map(from: incompleteJSON)
        XCTAssertEqual(profile.email, "alice@example.com")
    }

    func testMapHandlesNullAvatarURL() {
        let mapper = UserProfileMapper()

        let jsonWithNull: [String: Any] = [
            "name": "Alice",
            "email": "alice@example.com",
            "avatar_url": NSNull()
        ]

        // Force-unwrap on NSNull crashes
        let profile = mapper.map(from: jsonWithNull)
        XCTAssertNil(profile.avatarURL)
    }
}
```

**Correct (guard let with defaults handles missing and null values safely):**

```swift
import Foundation

struct UserProfile {
    let name: String
    let email: String
    let avatarURL: URL?
}

class UserProfileMapper {
    func map(from json: [String: Any]) -> UserProfile? {
        // Guard required fields — return nil instead of crashing
        guard let name = json["name"] as? String,
              let email = json["email"] as? String else {
            return nil
        }

        let avatarURL = (json["avatar_url"] as? String)
            .flatMap { URL(string: $0) }  // nil-safe chain

        return UserProfile(
            name: name,
            email: email,
            avatarURL: avatarURL
        )
    }
}
```
