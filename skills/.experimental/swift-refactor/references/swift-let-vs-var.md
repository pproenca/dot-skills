---
title: Use let for Constants, var for Variables
impact: CRITICAL
impactDescription: prevents accidental mutation, communicates intent, enables compiler optimizations
tags: swift, constants, variables, immutability, safety
---

## Use let for Constants, var for Variables

Swift distinguishes between constants (`let`) and variables (`var`). Constants cannot be reassigned after initialization, while variables can change. Prefer `let` by default - only use `var` when mutation is required.

**Incorrect (using var when value doesn't change):**

```swift
var userName = "Sophie"
var maxRetries = 3
var apiEndpoint = "https://api.example.com"

// These values never change but are declared as variables
// Compiler can't optimize, readers assume they might change
```

**Correct (let for immutable values):**

```swift
let userName = "Sophie"
let maxRetries = 3
let apiEndpoint = "https://api.example.com"

// Use var only when value needs to change
var currentRetryCount = 0
currentRetryCount += 1  // This actually changes

var lowTemp = 50
lowTemp = 40  // Reassignment is valid
lowTemp += 5  // Modification is valid
```

**Why this matters:**
- `let` prevents accidental mutation bugs
- Communicates intent to other developers
- Enables compiler optimizations
- Swift style prefers immutability

Reference: [Develop in Swift Tutorials - Swift Fundamentals](https://developer.apple.com/tutorials/develop-in-swift/swift-fundamentals)
