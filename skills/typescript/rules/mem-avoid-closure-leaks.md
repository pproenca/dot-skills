---
title: Avoid Closure Memory Leaks
impact: MEDIUM
impactDescription: prevents retained references in long-lived callbacks
tags: mem, closures, memory-leaks, callbacks, garbage-collection
---

## Avoid Closure Memory Leaks

Closures retain references to their outer scope variables. Long-lived callbacks can accidentally keep large objects alive, causing memory to grow unboundedly.

**Incorrect (closure retains entire scope):**

```typescript
function createDataProcessor(largeDataset: DataRecord[]): () => void {
  const processedIds = new Set<string>()

  return function processNext(): void {
    // This closure retains reference to largeDataset
    // even though it only needs processedIds
    const next = largeDataset.find(r => !processedIds.has(r.id))
    if (next) {
      processedIds.add(next.id)
      sendToServer(next)
    }
  }
}

// largeDataset (100MB) stays in memory as long as processNext exists
const processor = createDataProcessor(hugeDataset)
setInterval(processor, 1000)  // Runs forever, 100MB never freed
```

**Correct (extract only needed data):**

```typescript
function createDataProcessor(largeDataset: DataRecord[]): () => void {
  // Extract only what the closure needs
  const pendingIds = new Set(largeDataset.map(r => r.id))
  const recordById = new Map(largeDataset.map(r => [r.id, r]))

  // largeDataset can now be GC'd if caller releases it
  return function processNext(): void {
    const nextId = pendingIds.values().next().value
    if (nextId) {
      pendingIds.delete(nextId)
      const record = recordById.get(nextId)
      if (record) {
        sendToServer(record)
        recordById.delete(nextId)  // Allow record to be GC'd
      }
    }
  }
}
```

**For event handlers:**

```typescript
// Incorrect - handler retains component instance forever
class Dashboard {
  private largeCache: Map<string, Data> = new Map()

  initialize(): void {
    window.addEventListener('resize', () => {
      this.handleResize()  // 'this' keeps entire Dashboard alive
    })
  }
}

// Correct - remove listener when done, or use weak reference pattern
class Dashboard {
  private largeCache: Map<string, Data> = new Map()
  private resizeHandler: () => void

  initialize(): void {
    this.resizeHandler = () => this.handleResize()
    window.addEventListener('resize', this.resizeHandler)
  }

  destroy(): void {
    window.removeEventListener('resize', this.resizeHandler)
    this.largeCache.clear()
  }
}
```

Reference: [Node.js Memory Diagnostics](https://nodejs.org/en/learn/diagnostics/memory)
