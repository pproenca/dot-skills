---
title: Use Breakpoints to Debug Code
impact: MEDIUM
impactDescription: pause execution at specific lines, inspect variables, step through logic
tags: debug, xcode, debugging, breakpoints, inspection
---

## Use Breakpoints to Debug Code

Set breakpoints in Xcode to pause execution and inspect your app's state. Click the line number gutter to add a breakpoint. When paused, examine variables and step through code.

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
   - Continue (⌃⌘Y): Resume execution

**Conditional breakpoints:**
- Right-click breakpoint → Edit Breakpoint
- Add condition: `items.count > 10`
- Add action: Log message without stopping

Reference: [Develop in Swift Tutorials - Investigate and fix a bug](https://developer.apple.com/tutorials/develop-in-swift/investigate-and-fix-a-bug)
