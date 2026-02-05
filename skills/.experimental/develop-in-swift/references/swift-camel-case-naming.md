---
title: Use camelCase Naming Convention
impact: HIGH
impactDescription: follows Swift API guidelines, improves code readability, matches Apple frameworks
tags: swift, naming, conventions, style, readability
---

## Use camelCase Naming Convention

Swift uses camelCase: words are joined without spaces, and each word after the first is capitalized. Types use UpperCamelCase (PascalCase), while properties, methods, and variables use lowerCamelCase.

**Incorrect (inconsistent naming):**

```swift
struct user_profile {  // Wrong: snake_case for type
    var user_name: String  // Wrong: snake_case
    var ImageScale: CGFloat  // Wrong: starts with uppercase
}

func GetUserData() { }  // Wrong: starts with uppercase
let MAX_RETRIES = 3  // Wrong: SCREAMING_SNAKE_CASE
```

**Correct (Swift camelCase):**

```swift
struct UserProfile {  // UpperCamelCase for types
    var userName: String  // lowerCamelCase for properties
    var imageScale: CGFloat  // lowerCamelCase
}

func getUserData() { }  // lowerCamelCase for functions
let maxRetries = 3  // lowerCamelCase for constants

// SwiftUI examples
Text("Hello")
    .imageScale(.large)  // Modifier uses lowerCamelCase
    .foregroundStyle(.tint)
```

**Swift naming rules:**
- **Types** (struct, class, enum, protocol): `UpperCamelCase`
- **Properties, methods, variables**: `lowerCamelCase`
- **Constants**: `lowerCamelCase` (not SCREAMING_SNAKE_CASE)
- **Enum cases**: `lowerCamelCase`

Reference: [Develop in Swift Tutorials - Hello, SwiftUI](https://developer.apple.com/tutorials/develop-in-swift/hello-swiftui)
