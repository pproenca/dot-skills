---
title: Replace String IDs with Tagged Types
impact: LOW-MEDIUM
impactDescription: prevents accidental ID swaps between entity types
tags: type, identifier, tagged, type-safety, refactoring
---

## Replace String IDs with Tagged Types

String-typed identifiers are freely interchangeable at compile time -- passing an order ID where a user ID is expected compiles without error but causes silent data corruption or wrong-record lookups at runtime. Wrapping each identifier in a lightweight struct makes the compiler reject cross-entity mix-ups, turning runtime bugs into compile-time errors.

**Incorrect (String IDs are interchangeable, easy to swap by accident):**

```swift
func fetchOrderHistory(userID: String, organizationID: String) async throws -> [Order] {
    let url = baseURL
        .appendingPathComponent("orgs/\(organizationID)")
        .appendingPathComponent("users/\(userID)")
        .appendingPathComponent("orders")
    return try await network.get(url)
}

// Compiles fine but swaps the two IDs -- silent bug
let orders = try await fetchOrderHistory(
    userID: currentOrganization.id,
    organizationID: currentUser.id
)
```

**Correct (tagged types make swaps a compile error):**

```swift
struct UserID: Hashable, RawRepresentable {
    let rawValue: String
}

struct OrganizationID: Hashable, RawRepresentable {
    let rawValue: String
}

func fetchOrderHistory(userID: UserID, organizationID: OrganizationID) async throws -> [Order] {
    let url = baseURL
        .appendingPathComponent("orgs/\(organizationID.rawValue)")
        .appendingPathComponent("users/\(userID.rawValue)")
        .appendingPathComponent("orders")
    return try await network.get(url)
}

// Compiler error: cannot convert OrganizationID to UserID
let orders = try await fetchOrderHistory(
    userID: currentOrganization.id,
    organizationID: currentUser.id
)
```

Reference: [RawRepresentable](https://developer.apple.com/documentation/swift/rawrepresentable)
