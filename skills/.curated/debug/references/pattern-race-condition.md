---
title: Identify Race Condition Symptoms
impact: MEDIUM
impactDescription: prevents intermittent production failures
tags: pattern, race-condition, concurrency, threading
---

## Identify Race Condition Symptoms

Race conditions occur when multiple threads or processes access shared state without proper synchronization. Symptoms: intermittent failures, results depend on timing, works in debugger but fails in production.

**Incorrect (unsynchronized shared state):**

```java
public class Counter {
    private int count = 0;

    public void increment() {
        count++;  // Not atomic: read, add, write can interleave
    }

    public int getCount() {
        return count;
    }
}

// Two threads call increment() 1000 times each
// Expected: count = 2000
// Actual: count = 1847 (random, changes each run)
```

**Correct (synchronized access):**

```java
public class Counter {
    private final AtomicInteger count = new AtomicInteger(0);

    public void increment() {
        count.incrementAndGet();  // Atomic operation
    }

    public int getCount() {
        return count.get();
    }
}

// Two threads call increment() 1000 times each
// Result: count = 2000 (always correct)
```

**Race condition indicators:**
- Bug "disappears" when adding logging or breakpoints
- Different results on each run
- Works on developer machine, fails in CI/production
- Failures correlate with load or concurrent users
- "Heisenbug" that changes when observed

**Detection tools:**
- Thread sanitizers (TSan, Helgrind)
- Static analysis for data races
- Stress testing with high concurrency

Reference: [Valgrind Documentation - Helgrind Thread Analyzer](https://valgrind.org/docs/manual/hg-manual.html)
