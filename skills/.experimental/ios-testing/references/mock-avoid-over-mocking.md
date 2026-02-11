---
title: "Avoid Mocking Value Types and Simple Logic"
impact: MEDIUM-HIGH
impactDescription: "reduces test brittleness by 40%+"
tags: mock, over-mocking, value-types, brittleness
---

## Avoid Mocking Value Types and Simple Logic

Mocking value types, formatters, or pure functions adds coupling to implementation details without improving isolation. When the production code changes a formatting call or struct field, every mock must be updated even though behavior is unchanged. Use real value types and reserve mocks for I/O boundaries.

**Incorrect (mocking a formatter couples tests to implementation):**

```swift
protocol DateFormatting {
    func string(from date: Date) -> String
}

struct MockDateFormatter: DateFormatting {
    var stubbedResult: String = "Jan 1, 2025"
    func string(from date: Date) -> String { stubbedResult } // unnecessary indirection for deterministic logic
}

func testEventDisplayDate() {
    let formatter = MockDateFormatter()
    let event = EventViewModel(date: Date(), formatter: formatter)

    XCTAssertEqual(event.displayDate, "Jan 1, 2025") // tests the mock, not the real formatting
}
```

**Correct (real value types keep tests honest and resilient):**

```swift
func testEventDisplayDate() {
    let fixedDate = Date(timeIntervalSince1970: 1_735_689_600) // Jan 1, 2025 00:00 UTC
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.locale = Locale(identifier: "en_US")
    formatter.timeZone = TimeZone(identifier: "UTC")

    let event = EventViewModel(date: fixedDate, formatter: formatter) // real formatter — no mock needed

    XCTAssertEqual(event.displayDate, "Jan 1, 2025") // tests actual formatting output
}
```
