---
title: Never Store Reference Types Without Equatable Conformance
impact: CRITICAL
impactDescription: prevents 100% false-negative diffs from reference identity comparison
tags: diff, reference-types, classes, equatable, identity
---

## Never Store Reference Types Without Equatable Conformance

SwiftUI compares reference types (classes) by reference identity, not by value. Two class instances with identical data but different memory addresses will always compare as "changed", triggering unnecessary body re-evaluation. Either use value types (structs), add `Equatable` conformance to classes, or use `@SkipEquatable` if the property doesn't affect rendering.

**Incorrect (class without Equatable — body always re-evaluates even when data is identical):**

```swift
// Non-Equatable class — compared by reference identity
class UserProfile {
    var name: String
    var avatarURL: URL

    init(name: String, avatarURL: URL) {
        self.name = name
        self.avatarURL = avatarURL
    }
}

@Equatable
struct ProfileHeader: View {
    let profile: UserProfile  // reference type without Equatable
    // SwiftUI compares by identity (===), NOT by value
    // Every new instance triggers body re-evaluation even if data is the same

    var body: some View {
        HStack {
            AsyncImage(url: profile.avatarURL)
            Text(profile.name)
        }
    }
}
```

**Correct (option 1 — use a value type):**

```swift
struct UserProfile: Equatable {
    let name: String
    let avatarURL: URL
}

@Equatable
struct ProfileHeader: View {
    let profile: UserProfile  // value type — compared by value

    var body: some View {
        HStack {
            AsyncImage(url: profile.avatarURL)
            Text(profile.name)
        }
    }
}
```

**Correct (option 2 — add Equatable to the class):**

```swift
class UserProfile: Equatable {
    let name: String
    let avatarURL: URL

    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        lhs.name == rhs.name && lhs.avatarURL == rhs.avatarURL
    }

    init(name: String, avatarURL: URL) {
        self.name = name
        self.avatarURL = avatarURL
    }
}
```

**Correct (option 3 — @SkipEquatable if property doesn't affect rendering):**

```swift
@Equatable
struct ProfileHeader: View {
    let displayName: String
    @SkipEquatable let analytics: AnalyticsTracker  // class, not rendered

    var body: some View {
        Text(displayName)
    }
}
```

Reference: [WWDC23 — Demystify SwiftUI Performance](https://developer.apple.com/wwdc23/10160)
