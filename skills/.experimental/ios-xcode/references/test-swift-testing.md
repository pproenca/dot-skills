---
title: Write Unit Tests with Swift Testing
impact: HIGH
impactDescription: verify model logic, catch regressions, document expected behavior with clear failure messages
tags: test, swift, testing, unit-tests, swift-testing, tdd, expect
---

## Write Unit Tests with Swift Testing

Swift Testing (new framework) uses `@Test` attribute and `#expect` macro for assertions. Write tests to verify your model logic works correctly before building UI. The `#expect` macro provides clear, readable failure messages that pinpoint exactly what went wrong.

**Incorrect (no tests or old XCTest):**

```swift
// Code without tests - bugs discovered in production
class Scoreboard {
    func calculateScore() -> Int { ... }
}

// Old XCTest style (still works but verbose)
class ScoreboardTests: XCTestCase {
    func testCalculateScore() {
        XCTAssertEqual(scoreboard.calculateScore(), 100)
    }
}
```

**Correct (Swift Testing):**

```swift
import Testing

// Test struct with @Test methods
struct ScoreboardTests {

    @Test func initialScoreIsZero() {
        let scoreboard = Scoreboard()
        #expect(scoreboard.score == 0)
    }

    @Test func scoreIncreasesOnCorrectAnswer() {
        var scoreboard = Scoreboard()
        scoreboard.recordCorrectAnswer()
        #expect(scoreboard.score == 10)
    }

    @Test func scoreDecreasesOnWrongAnswer() {
        var scoreboard = Scoreboard()
        scoreboard.score = 20
        scoreboard.recordWrongAnswer()
        #expect(scoreboard.score == 15)
    }

    @Test func scoreNeverGoesNegative() {
        var scoreboard = Scoreboard()
        scoreboard.recordWrongAnswer()
        #expect(scoreboard.score >= 0)
    }
}

// Parameterized tests
@Test(arguments: [1, 2, 3, 5, 8])
func fibonacciNumbers(input: Int) {
    #expect(fibonacci(input) > 0)
}
```

**Testing real model logic with #expect:**

```swift
import Testing

@Test func addingProductToCartIncreasesTotal() {
    var cart = ShoppingCart()
    let coffee = Product(id: "coffee-01", name: "Coffee Beans", price: 12.99)

    cart.add(coffee, quantity: 2)

    #expect(cart.items.count == 1)
    #expect(cart.totalPrice == 25.98) // 12.99 * 2
}

@Test func addingSameProductMergesQuantity() {
    var cart = ShoppingCart()
    let coffee = Product(id: "coffee-01", name: "Coffee Beans", price: 12.99)

    cart.add(coffee, quantity: 1)
    cart.add(coffee, quantity: 3)

    #expect(cart.items.count == 1) // merged, not duplicated
    #expect(cart.items[0].quantity == 4)
}
```

**Swift Testing features:**
- `@Test` attribute marks test functions
- `#expect(condition)` for assertions
- Parameterized tests with `arguments:`
- Better error messages than XCTest
- Works alongside XCTest

Reference: [Develop in Swift Tutorials - Add functionality with Swift Testing](https://developer.apple.com/tutorials/develop-in-swift/add-functionality-with-swift-testing)
