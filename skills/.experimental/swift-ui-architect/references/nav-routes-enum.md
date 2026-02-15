---
title: Define All Routes as a Hashable Enum
impact: HIGH
impactDescription: eliminates stringly-typed navigation, compiler-verified routes
tags: nav, routes, enum, type-safe, hashable
---

## Define All Routes as a Hashable Enum

Every navigation destination in a feature must be defined as a case in a `Hashable` enum. This provides compile-time verification that all routes are handled, enables pattern matching for deep link resolution, and documents the feature's navigation graph in one place. Never use string-based routing.

**Incorrect (stringly-typed navigation — no compile-time safety, easy to mistype):**

```swift
// String-based routing — typos compile fine, crash at runtime
struct AppRouter {
    func navigate(to screen: String, params: [String: Any]) {
        switch screen {
        case "orderDetail":
            // Runtime cast — crashes if wrong type
            let id = params["id"] as! String
            showOrderDetail(id: id)
        case "userProfile":
            let userId = params["userId"] as! String
            showProfile(userId: userId)
        case "setttings":  // Typo — compiles fine, never matches
            showSettings()
        default:
            break  // Silent failure for unknown routes
        }
    }
}

// Usage — no IDE autocomplete, no type safety
router.navigate(to: "orderDetial", params: ["id": 42])
// Typo in route name — compiles, silently fails at runtime
// Wrong param type (Int vs String) — compiles, crashes at runtime
```

**Correct (Hashable enum — compiler-verified, exhaustive, self-documenting):**

```swift
// Every destination is a case with typed associated values
// Adding a new route forces handling in all switch statements
enum OrderRoute: Hashable {
    case list
    case detail(orderId: String)
    case tracking(orderId: String)
    case refund(orderId: String, reason: RefundReason?)
    case review(orderId: String, rating: Int)
}

// Compiler verifies ALL cases are handled — missing one is a build error
extension OrderRoute {
    // Deep link resolution via pattern matching
    init?(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.host == "orders" else {
            return nil
        }

        let pathComponents = components.path.split(separator: "/")

        switch pathComponents.first.map(String.init) {
        case nil:
            self = .list
        case "detail":
            guard let id = pathComponents.dropFirst().first.map(String.init) else {
                return nil
            }
            self = .detail(orderId: id)
        case "tracking":
            guard let id = pathComponents.dropFirst().first.map(String.init) else {
                return nil
            }
            self = .tracking(orderId: id)
        default:
            return nil
        }
    }
}

// Usage — IDE autocomplete, type-safe parameters, compile-time verification
coordinator.navigate(to: .detail(orderId: "abc-123"))
coordinator.navigate(to: .refund(orderId: "abc-123", reason: .damaged))

// Adding a new case:
// case invoice(orderId: String)
// Immediately triggers "Switch must be exhaustive" errors
// in coordinator, deep link handler, and analytics — nothing is missed
```

Reference: [Advanced iOS App Architecture (4th Ed.)](https://www.kodeco.com/books/advanced-ios-app-architecture)
