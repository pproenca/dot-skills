---
title: Profile SwiftUI with Instruments
impact: MEDIUM
impactDescription: reduces optimization time by 5-10x by targeting actual bottlenecks
tags: perf, instruments, profiling, debugging, optimization
---

## Profile SwiftUI with Instruments

Don't guess at performance issues. Use Instruments to identify actual bottlenecks in view body execution, re-renders, and layout.

**Incorrect (guessing at performance issues):**

```swift
struct ProductList: View {
    let products: [Product]

    var body: some View {
        // "This feels slow, let me add memoization everywhere"
        List(products) { product in
            ProductRow(product: product)
        }
        // Random optimizations without measuring
        // May not address the actual problem
    }
}
```

**Correct (profile then optimize):**

```swift
struct ProductList: View {
    let products: [Product]

    var body: some View {
        let _ = Self._printChanges()  // Debug: see why body runs

        List(products) { product in
            ProductRow(product: product)
        }
        // 1. Profile with Instruments (Cmd+I)
        // 2. Find actual bottleneck
        // 3. Fix specific issue
        // 4. Verify improvement
    }
}
```

**Instruments setup:**

1. Profile in Release mode (Cmd+I or Product > Profile)
2. Select "SwiftUI" template (Instruments 26+)
3. Or use "Time Profiler" + "SwiftUI View Body" instruments

**Common issues and solutions:**

| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| Body runs on every frame | Animation on parent | Extract animated view |
| 100+ body calls per second | State at wrong level | Move state down |
| Slow single body | Expensive computation | Cache or move to model |
| Memory growth | Unbounded list | Use LazyVStack |

**Best practice:** Profile before and after optimization to verify improvements.

Reference: [WWDC25: Optimize SwiftUI Performance](https://developer.apple.com/videos/play/wwdc2025/306/)
