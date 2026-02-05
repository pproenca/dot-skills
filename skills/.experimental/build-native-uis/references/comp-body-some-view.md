---
title: Return some View from body Property
impact: CRITICAL
impactDescription: foundation of every SwiftUI view
tags: comp, swiftui, view-protocol, opaque-type, struct
---

## Return some View from body Property

Every SwiftUI view must be a struct conforming to the `View` protocol, which requires a computed `body` property returning `some View`. Without this contract the compiler cannot participate in the declarative diffing system, and the struct is just inert data.

**Incorrect (struct without View conformance or body property):**

```swift
struct ProfileHeader {
    let username: String
    let avatarURL: URL

    func render() -> Text {
        Text(username)
            .font(.headline)
    }
}

struct SettingsRow {
    let title: String

    func display() -> some View { // no View conformance
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
        }
    }
}
```

**Correct (struct conforms to View with body property):**

```swift
struct ProfileHeader: View {
    let username: String
    let avatarURL: URL

    var body: some View { // required by View protocol
        Text(username)
            .font(.headline)
    }
}

struct SettingsRow: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
