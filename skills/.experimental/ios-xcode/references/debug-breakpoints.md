---
title: Use Breakpoints to Debug Code
impact: MEDIUM
impactDescription: pause execution to inspect variable values and step through logic without print statements
tags: debug, xcode, debugging, breakpoints, inspection, runtime
---

## Use Breakpoints to Debug Code

Scattering `print()` statements through your code to trace values is slow, clutters output, and risks being shipped to production. Breakpoints pause execution at a specific line so you can inspect every variable in scope, step through logic, and evaluate expressions in the debugger console without modifying source code.

**Incorrect (print debugging only):**

```swift
// Print statements are verbose and slow
func processData() {
    print("Starting processData")
    print("items count: \(items.count)")
    for item in items {
        print("Processing: \(item)")
        // ...
        print("Done processing: \(item)")
    }
    print("Finished processData")
}
```

**Another incorrect example (scattered print statements to trace a bug):**

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

**Correct (breakpoint debugging):**

```swift
func processData() {
    // Set breakpoint on this line (click line number gutter)
    for item in items {
        let result = transform(item)  // <- Breakpoint here
        // Inspect 'item' and 'result' in Variables view
        // Step over (F6) to see next iteration
    }
}

// Clean code debugged with breakpoints
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

// Use print sparingly for production logging
func fetchData() async {
    #if DEBUG
    print("Fetching data from \(url)")
    #endif
    // ...
}
```

**Debugging workflow:**
1. **Set breakpoint**: Click line number gutter
2. **Run app**: Execution pauses at breakpoint
3. **Inspect variables**: View values in Debug area
4. **Step controls**:
   - Step Over (F6): Execute current line
   - Step Into (F7): Enter function
   - Step Out (F8): Exit function
   - Continue (Control+Command+Y): Resume execution

**Conditional breakpoints:**
- Right-click breakpoint > Edit Breakpoint
- Add condition: `items.count > 10`
- Add action: Log message without stopping

Reference: [Develop in Swift Tutorials - Investigate and fix a bug](https://developer.apple.com/tutorials/develop-in-swift/investigate-and-fix-a-bug)
