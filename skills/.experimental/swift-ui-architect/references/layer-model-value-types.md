---
title: Domain Models Are Structs, Never Classes
impact: MEDIUM-HIGH
impactDescription: value semantics prevent shared mutable state bugs and enable SwiftUI diffing
tags: layer, models, structs, value-types, equatable
---

## Domain Models Are Structs, Never Classes

Domain models (User, Order, Product) must be structs conforming to `Equatable` and `Sendable`. Value types have predictable copy semantics — mutations in one view model never unexpectedly affect another. They're also naturally diffable by SwiftUI, thread-safe by default, and trivially serializable.

**Incorrect (class model with var properties — shared mutable state, reference semantics):**

```swift
// Reference type — shared across view models, mutations propagate unexpectedly
class User {
    var id: String
    var name: String
    var email: String
    var avatarURL: URL?
    var preferences: UserPreferences
    var orderHistory: [Order]

    init(id: String, name: String, email: String, avatarURL: URL?,
         preferences: UserPreferences, orderHistory: [Order]) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.preferences = preferences
        self.orderHistory = orderHistory
    }
}

// Bug: two view models share the same User reference
let user = User(id: "1", name: "Alice", email: "alice@example.com",
                avatarURL: nil, preferences: .default, orderHistory: [])

let profileVM = ProfileViewModel(user: user)
let settingsVM = SettingsViewModel(user: user)

// Mutation in settingsVM silently affects profileVM
settingsVM.user.name = "Bob"
print(profileVM.user.name)  // "Bob" — unexpected side effect!

// Not Equatable by default — SwiftUI can't diff efficiently
// Not Sendable — unsafe to pass across actor boundaries
// Not Codable by default — manual serialization needed
```

**Correct (struct with let properties — value semantics, diffable, thread-safe):**

```swift
// Value type — copies are independent, mutations are explicit
struct User: Equatable, Sendable, Codable {
    let id: String
    let name: String
    let email: String
    let avatarURL: URL?
    let preferences: UserPreferences
    let orderHistory: [Order]
}

// Each view model gets its own independent copy
let user = User(id: "1", name: "Alice", email: "alice@example.com",
                avatarURL: nil, preferences: .default, orderHistory: [])

let profileVM = ProfileViewModel(user: user)
let settingsVM = SettingsViewModel(user: user)

// Mutation creates a new value — original is unchanged
let updatedUser = User(
    id: user.id,
    name: "Bob",
    email: user.email,
    avatarURL: user.avatarURL,
    preferences: user.preferences,
    orderHistory: user.orderHistory
)
settingsVM.updateUser(updatedUser)
print(profileVM.user.name)  // "Alice" — unaffected, as expected

// Equatable: SwiftUI diffs efficiently — only re-renders when values change
// Sendable: safe to pass across actor boundaries (async/await, MainActor)
// Codable: automatic serialization for network/persistence

// For updates, use a builder pattern or functional copy
extension User {
    func with(name: String? = nil, email: String? = nil) -> User {
        User(
            id: id,
            name: name ?? self.name,
            email: email ?? self.email,
            avatarURL: avatarURL,
            preferences: preferences,
            orderHistory: orderHistory
        )
    }
}

// Clean, explicit mutations
let renamed = user.with(name: "Bob")  // New value, original unchanged
```

Reference: [Advanced iOS App Architecture (4th Ed.)](https://www.kodeco.com/books/advanced-ios-app-architecture)
