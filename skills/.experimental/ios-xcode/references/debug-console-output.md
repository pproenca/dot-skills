---
title: Use Debug Console for Runtime Inspection
impact: MEDIUM
impactDescription: evaluate expressions during pause, call methods, test fixes live
tags: debug, xcode, debugging, console, lldb, inspection
---

## Use Debug Console for Runtime Inspection

When paused at a breakpoint, use the debug console to evaluate expressions, inspect objects, and test fixes. Type `po variableName` to print object descriptions.

**Incorrect (print statements instead of debugger):**

```swift
// Don't litter code with print statements
func processData(_ data: [Item]) {
    print("data count: \(data.count)")  // Clutters console
    print("first item: \(data.first)")   // Hard to find
    for item in data {
        print("processing: \(item)")     // Too much noise
    }
}
```

**Debug console commands:**

```lldb
// Print object description
(lldb) po friend
▿ Friend
  - name: "Sophie"
  - birthday: 2024-01-15

// Print primitive value
(lldb) p count
(Int) $R0 = 42

// Evaluate expressions
(lldb) po friends.count
3

(lldb) po friends.filter { $0.name.contains("S") }
▿ 1 element
  - 0 : Friend(name: "Sophie")

// Call methods
(lldb) po friend.name.uppercased()
"SOPHIE"

// Modify values (use with caution)
(lldb) expression friend.name = "Alex"
```

**Console in SwiftUI debugging:**

```swift
struct ContentView: View {
    @State private var items: [Item] = []

    var body: some View {
        List(items) { item in
            Text(item.name)
        }
        .onAppear {
            // Set breakpoint here
            loadItems()
            // In console: po items
        }
    }
}
```

**Useful lldb commands:**
- `po expression` - Print object (calls debugDescription)
- `p expression` - Print value with type
- `expression` - Evaluate/modify values
- `bt` - Show call stack (backtrace)
- `frame variable` - Show all local variables

Reference: [Develop in Swift Tutorials - Investigate and fix a bug](https://developer.apple.com/tutorials/develop-in-swift/investigate-and-fix-a-bug)
