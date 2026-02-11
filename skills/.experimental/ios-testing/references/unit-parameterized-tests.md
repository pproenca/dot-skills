---
title: "Use Parameterized Tests for Input Variations"
impact: CRITICAL
impactDescription: "10x test coverage from single test function"
tags: unit, parameterized, swift-testing, coverage
---

## Use Parameterized Tests for Input Variations

Copy-pasting test functions with different inputs creates maintenance debt and hides the pattern being tested. Parameterized tests declare input-output pairs once, then Swift Testing runs each combination as an independent case with its own pass/fail status, making it trivial to add new edge cases.

**Incorrect (five copy-pasted functions testing the same logic):**

```swift
@Suite struct CurrencyFormatterTests {
    let formatter = CurrencyFormatter()

    @Test func formatsUSD() {
        #expect(formatter.format(amount: 1234.5, currency: .usd) == "$1,234.50")
    }

    @Test func formatsEUR() {
        #expect(formatter.format(amount: 1234.5, currency: .eur) == "€1,234.50")
    }

    @Test func formatsGBP() {
        #expect(formatter.format(amount: 1234.5, currency: .gbp) == "£1,234.50")
    }

    @Test func formatsJPY() { // each new currency = entire new function
        #expect(formatter.format(amount: 1234.5, currency: .jpy) == "¥1,235")
    }

    @Test func formatsZeroUSD() {
        #expect(formatter.format(amount: 0, currency: .usd) == "$0.00")
    }
}
```

**Correct (one function covers all cases, adding a row takes one line):**

```swift
@Suite struct CurrencyFormatterTests {
    let formatter = CurrencyFormatter()

    @Test(arguments: [
        (1234.5, Currency.usd, "$1,234.50"),
        (1234.5, Currency.eur, "€1,234.50"),
        (1234.5, Currency.gbp, "£1,234.50"),
        (1234.5, Currency.jpy, "¥1,235"),
        (0,      Currency.usd, "$0.00"),
    ])
    func formatsAmount(amount: Double, currency: Currency, expected: String) {
        #expect(formatter.format(amount: amount, currency: currency) == expected) // each tuple runs as independent test case
    }
}
```
