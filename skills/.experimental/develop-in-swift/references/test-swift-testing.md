---
title: Write Unit Tests with Swift Testing
impact: MEDIUM-HIGH
impactDescription: verify model logic, catch regressions, document expected behavior
tags: test, swift, testing, unit-tests, swift-testing, tdd
---

## Write Unit Tests with Swift Testing

Swift Testing (new framework) uses `@Test` attribute and `#expect` macro for assertions. Write tests to verify your model logic works correctly before building UI.

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

**Swift Testing features:**
- `@Test` attribute marks test functions
- `#expect(condition)` for assertions
- Parameterized tests with `arguments:`
- Better error messages than XCTest
- Works alongside XCTest

Reference: [Develop in Swift Tutorials - Add functionality with Swift Testing](https://developer.apple.com/tutorials/develop-in-swift/add-functionality-with-swift-testing)
