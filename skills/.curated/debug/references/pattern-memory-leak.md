---
title: Detect Memory Leak Patterns
impact: MEDIUM
impactDescription: prevents out-of-memory crashes
tags: pattern, memory-leak, resources, profiling
---

## Detect Memory Leak Patterns

Memory leaks occur when allocated memory is never released. Symptoms: gradually increasing memory usage, eventual out-of-memory crashes, performance degradation over time. Look for event listeners not removed, caches without bounds, and circular references.

**Incorrect (memory leak patterns):**

```javascript
// Leak 1: Event listeners never removed
class Dashboard {
  constructor() {
    window.addEventListener('resize', this.handleResize)  // Never removed
  }
  // Missing: componentWillUnmount to remove listener
}

// Leak 2: Unbounded cache
const cache = {}
function getCachedData(key) {
  if (!cache[key]) {
    cache[key] = fetchData(key)  // Cache grows forever
  }
  return cache[key]
}

// Leak 3: Closures holding references
function createHandlers(elements) {
  const handlers = []
  for (const el of elements) {
    handlers.push(() => {
      console.log(el)  // Each closure holds reference to element
    })
  }
  return handlers  // Elements can't be garbage collected
}
```

**Correct (memory-safe patterns):**

```javascript
// Fixed 1: Remove event listeners
class Dashboard {
  constructor() {
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener('resize', this.handleResize)
  }
  destroy() {
    window.removeEventListener('resize', this.handleResize)
  }
}

// Fixed 2: Bounded cache with LRU eviction
const cache = new LRUCache({ max: 1000 })
function getCachedData(key) {
  if (!cache.has(key)) {
    cache.set(key, fetchData(key))
  }
  return cache.get(key)
}

// Fixed 3: WeakRef for optional references
function createHandlers(elements) {
  return elements.map(el => {
    const weakRef = new WeakRef(el)
    return () => {
      const element = weakRef.deref()
      if (element) console.log(element)
    }
  })
}
```

**Memory leak detection:**
- Memory profilers: Chrome DevTools, Valgrind, dotMemory
- Monitor heap size over time in production
- Test with long-running automated scenarios

Reference: [Netdata - How to Find Memory Leaks](https://www.netdata.cloud/academy/how-to-find-memory-leak-in-c/)
