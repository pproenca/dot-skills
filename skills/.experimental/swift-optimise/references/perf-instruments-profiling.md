---
title: Profile with SwiftUI Instruments Before Optimizing
impact: HIGH
impactDescription: prevents wasted effort on non-bottlenecks -- 80% of performance issues come from 20% of code that only profiling can identify
tags: perf, instruments, profiling, measurement, optimization, xcode
---

## Profile with SwiftUI Instruments Before Optimizing

Premature optimization wastes effort on code paths that are not actual bottlenecks. The SwiftUI Instruments template reveals which views re-evaluate most frequently, how long each body takes, and where the render pipeline stalls. Always measure before applying optimization patterns.

**Incorrect (guessing at the bottleneck):**

```swift
// Developer assumed LazyVStack was the problem and added
// Equatable to every row -- but the actual bottleneck was
// an expensive date formatter called in body
struct MessageRow: View, Equatable {
    let message: Message

    static func == (lhs: MessageRow, rhs: MessageRow) -> Bool {
        lhs.message.id == rhs.message.id &&
        lhs.message.updatedAt == rhs.message.updatedAt
    }

    var body: some View {
        HStack {
            Text(message.sender)
            Spacer()
            // This creates a new DateFormatter on every call
            Text(DateFormatter.localizedString(
                from: message.date,
                dateStyle: .short,
                timeStyle: .short
            ))
        }
    }
}
```

**Correct (profile first, then fix the actual bottleneck):**

```swift
struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack {
            Text(message.sender)
            Spacer()
            // Cache the formatted date on the model, not in the view
            Text(message.formattedDate)
        }
    }
}

extension Message {
    // Computed once when message is created, reused across redraws
    var formattedDate: String {
        Self.dateFormatter.string(from: date)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
```

**How to profile SwiftUI:**

1. **Open Instruments:** Product > Profile (Cmd+I) in Xcode
2. **Choose template:** Select "SwiftUI" (or "Time Profiler" for general CPU)
3. **Record:** Interact with the problem area (scroll, navigate, animate)
4. **Analyze body evaluations:** Look for views with high evaluation counts or long durations
5. **Check for hangs:** The "Hangs" instrument shows main thread stalls > 250ms

**Key metrics to watch:**
- **Body evaluation count** -- if a view evaluates 100x during a scroll, it needs decomposition
- **Body evaluation duration** -- if `body` takes > 1ms, it contains expensive work
- **View update count** -- mismatches between evaluations and updates indicate wasted diffs
- **Main thread hangs** -- stalls > 250ms are visible as frame drops

**Profiling checklist before optimizing:**
- [ ] Profile in Release mode (Debug has 10-100x overhead for SwiftUI)
- [ ] Record the specific user flow that feels slow
- [ ] Identify the top 3 views by evaluation count
- [ ] Check if body durations exceed 1ms for any view
- [ ] Verify the optimization actually improves the metric

Reference: [Understanding and improving SwiftUI performance](https://developer.apple.com/documentation/Xcode/understanding-and-improving-swiftui-performance)
