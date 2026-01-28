---
title: Avoid Closure Memory Leaks
impact: LOW-MEDIUM
impactDescription: prevents retained references from causing memory growth
tags: mem, closures, memory-leak, references, garbage-collection
---

## Avoid Closure Memory Leaks

Closures can retain references to large objects, preventing garbage collection. Break reference chains in cleanup.

**Incorrect (closure retains large data):**

```tsx
function DataProcessor({ data }) {
  // Large data array (1MB+)
  const processedData = useMemo(() => heavyProcess(data), [data])

  useEffect(() => {
    // Closure captures processedData
    const interval = setInterval(() => {
      // This closure keeps processedData alive
      // even after component unmounts (until interval cleared)
      console.log(processedData.length)
      sendAnalytics(processedData.summary)
    }, 60000)

    return () => clearInterval(interval)  // Clears interval, but...
    // processedData may still be retained briefly
  }, [processedData])

  // ...
}
```

**Correct (break reference chains):**

```tsx
function DataProcessor({ data }) {
  const processedData = useMemo(() => heavyProcess(data), [data])

  useEffect(() => {
    // Extract only what's needed
    const summary = processedData.summary
    const count = processedData.length

    const interval = setInterval(() => {
      // Closure captures only small extracted values
      console.log(count)
      sendAnalytics(summary)
    }, 60000)

    return () => clearInterval(interval)
  }, [processedData])

  // ...
}
```

**Use refs to avoid closure capture:**

```tsx
function VideoPlayer({ videoUrl }) {
  // Ref doesn't cause re-closure creation
  const videoRef = useRef(null)
  const playerRef = useRef(null)

  useEffect(() => {
    playerRef.current = new VideoPlayer(videoUrl)

    const handleProgress = () => {
      // Access via ref, not closure
      const player = playerRef.current
      if (player) {
        updateProgress(player.currentTime)
      }
    }

    playerRef.current.on('progress', handleProgress)

    return () => {
      // Clean up player
      if (playerRef.current) {
        playerRef.current.destroy()
        playerRef.current = null  // Break reference
      }
    }
  }, [videoUrl])

  // ...
}
```

**Avoid capturing 'this' in classes:**

```tsx
// If using class components
class DataView extends Component {
  data = null

  componentDidMount() {
    fetchData().then(data => {
      this.data = data
      this.startPolling()
    })
  }

  startPolling() {
    // Arrow function captures 'this' and all its properties
    this.interval = setInterval(() => {
      this.processData(this.data)
    }, 5000)
  }

  componentWillUnmount() {
    clearInterval(this.interval)
    this.data = null  // Break reference explicitly
  }
}
```

**Use WeakRef for optional caching:**

```tsx
// For caches that should allow garbage collection
class ComponentCache {
  private cache = new Map<string, WeakRef<object>>()

  set(key: string, value: object) {
    this.cache.set(key, new WeakRef(value))
  }

  get(key: string): object | undefined {
    const ref = this.cache.get(key)
    return ref?.deref()  // Returns undefined if GC'd
  }
}
```

**Debug memory leaks:**

```tsx
// Add temporary logging to find leaks
useEffect(() => {
  console.log('Component mounted, data size:', data.length)

  return () => {
    console.log('Component unmounting')
    // Check if cleanup runs as expected
  }
}, [])

// Use React DevTools Profiler
// Use Chrome DevTools Memory tab
// Take heap snapshots before/after navigation
```

**Common closure leak sources:**
- setInterval/setTimeout callbacks
- Event listener handlers
- Promise chains
- Animation callbacks
- Subscription handlers

Reference: [JavaScript Memory Management](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Memory_Management)
