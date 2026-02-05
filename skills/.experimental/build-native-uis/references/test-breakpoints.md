---
title: Use Breakpoints to Debug Runtime Issues
impact: MEDIUM
impactDescription: breakpoints pause execution to inspect variable values without adding print statements
tags: test, breakpoints, debugging, xcode, runtime
---

## Use Breakpoints to Debug Runtime Issues

Scattering `print()` statements through your code to trace values is slow, clutters output, and risks being shipped to production. Breakpoints pause execution at a specific line so you can inspect every variable in scope, step through logic, and evaluate expressions in the debugger console without modifying source code.

**Incorrect (scattered print statements to trace a bug):**

```swift
struct TipCalculator {
    func calculateTip(billAmount: Double, tipPercentage: Double, splitCount: Int) -> Double {
        print("billAmount: \(billAmount)")
        print("tipPercentage: \(tipPercentage)")
        let tipAmount = billAmount * tipPercentage
        print("tipAmount: \(tipAmount)")
        let totalWithTip = billAmount + tipAmount
        print("totalWithTip: \(totalWithTip)")
        let perPerson = totalWithTip / Double(splitCount)
        print("perPerson: \(perPerson)")
        return perPerson
    }
}
```

**Correct (clean code debugged with breakpoints in Xcode):**

```swift
struct TipCalculator {
    func calculateTip(billAmount: Double, tipPercentage: Double, splitCount: Int) -> Double {
        let tipAmount = billAmount * tipPercentage
        let totalWithTip = billAmount + tipAmount
        let perPerson = totalWithTip / Double(splitCount) // set breakpoint here to inspect all values
        return perPerson
    }
}
// In Xcode: click the line gutter to add a breakpoint, then use
// the debug console to evaluate expressions like `po tipAmount`
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
