---
title: Use In-Memory Containers for Preview Isolation
impact: MEDIUM
impactDescription: prevents data accumulation across preview refreshes
tags: preview, in-memory, isolation, container
---

## Use In-Memory Containers for Preview Isolation

Previews using persistent storage accumulate data with every Xcode refresh — you see 50 copies of "Elena" after 50 refreshes. In-memory containers start fresh every time, ensuring previews always show exactly the data you defined.

**Incorrect (persistent store — data duplicates on every refresh):**

```swift
#Preview {
    ContentView()
        .modelContainer(for: Friend.self)
    // Uses on-disk storage by default
    // Each Xcode refresh inserts another copy of sample data
    // After 50 refreshes: 50 Elenas, 50 Grahams
}
```

**Correct (in-memory container — clean data every refresh):**

```swift
#Preview {
    ContentView()
        .modelContainer(SampleData.shared.modelContainer)
    // SampleData uses ModelConfiguration(isStoredInMemoryOnly: true)
    // Every refresh starts with exactly the sample data you defined
}
```

**When NOT to use:**
- When testing persistence behavior itself (e.g., verifying data survives a container reload)
- Integration tests that need to validate on-disk storage paths

**Benefits:**
- Predictable preview output regardless of how many times you refresh
- Faster preview startup — no disk I/O
- No leftover test data polluting the simulator's persistent store

Reference: [Develop in Swift — Navigate Sample Data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data)
