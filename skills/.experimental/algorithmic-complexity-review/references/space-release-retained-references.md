---
title: Release References That Prevent Garbage Collection
impact: LOW-MEDIUM
impactDescription: Prevents long-tail memory growth; GC pressure shows up as latency, not OOM
tags: space, memory-leak, gc, closure, retention
---

## Release References That Prevent Garbage Collection

A garbage collector reclaims only what's unreachable. Long-lived containers (module-level caches, event listeners, timers, closures captured by long-lived callbacks) keep transitively-reachable objects alive forever — what looks like a memory leak in a GC'd language is almost always an unintended retained reference. In long-running services, this manifests as a slow heap creep that eventually triggers GC pauses (latency spikes), then OOM hours or days later. The fixes are mechanical once you recognize the pattern: bounded caches, weak references for parent→child back-pointers, explicit unsubscription, and avoiding closing over heavy state in callbacks.

**Incorrect (unbounded cache + closure over heavy state):**

```javascript
const cache = new Map();   // module-level, never trimmed

function handleRequest(req) {
  const heavyResponse = expensiveCompute(req);
  cache.set(req.id, () => heavyResponse);   // closure pins `heavyResponse` forever
  // …
}
// Every request leaves a closure that retains the full response object
```

**Correct (bounded cache, no closure over heavy state):**

```javascript
import LRU from 'lru-cache';
const cache = new LRU({ max: 1000 });     // bounded, evicts oldest

function handleRequest(req) {
  const heavyResponse = expensiveCompute(req);
  cache.set(req.id, summarize(heavyResponse));   // store only what's needed
}
```

**Alternative (weak references for parent→child pointers):**

```javascript
// Avoid: child pinning parent in memory because parent.children[] points to child
class Parent {
  constructor() { this.children = []; }
}
class Child {
  constructor(parent) { this.parent = parent; }   // back-pointer pins parent
}

// Better: WeakRef for the back-pointer
class Child {
  constructor(parent) { this.parentRef = new WeakRef(parent); }
  getParent() { return this.parentRef.deref(); }
}
```

**Alternative (clean up event listeners and timers):**

```javascript
// Long-lived listener pins everything its closure references
useEffect(() => {
  const handler = e => doSomething(state);
  window.addEventListener('resize', handler);
  return () => window.removeEventListener('resize', handler);   // critical
}, [state]);
```

**When NOT to use this pattern:**
- For short-lived processes (CLI scripts, request handlers) — retention doesn't matter; GC will reclaim everything when the process exits.

Reference: [V8 blog — understanding garbage collection and retention](https://v8.dev/blog/trash-talk)
