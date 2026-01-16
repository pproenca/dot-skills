---
title: Profile Memory Usage with Development Tools
impact: LOW-MEDIUM
impactDescription: prevents 10-100MB memory leaks from reaching production
tags: mem, profiling, debugging, flipper, hermes
---

## Profile Memory Usage with Development Tools

Use React Native DevTools, Flipper, and Hermes profiling to identify memory leaks and excessive allocations before they cause production crashes.

**Incorrect (no memory monitoring, leaks ship to production):**

```typescript
function App() {
  // No memory profiling setup
  // Memory leaks accumulate undetected
  // Users experience crashes after prolonged use
  return <RootNavigator />
}
```

**Correct (proactive memory monitoring):**

```typescript
import { useEffect } from 'react'

function App() {
  useMemoryMonitor()  // Development-only memory tracking
  return <RootNavigator />
}

function useMemoryMonitor() {
  useEffect(() => {
    if (__DEV__ && global.HermesInternal) {
      const interval = setInterval(() => {
        const stats = global.HermesInternal.getHeapStatistics()
        console.log('Memory:', Math.round(stats.heapSize / 1024 / 1024) + 'MB')
      }, 5000)
      return () => clearInterval(interval)
    }
  }, [])
}
```

**Setup React Native DevTools:**

```bash
# Open DevTools from Metro terminal
j  # Press 'j' to open React Native DevTools

# Or use the command
npx react-native doctor
```

**Enable Performance Monitor overlay:**

```typescript
import { PerformanceMonitor } from 'react-native'

// In development, enable performance overlay
if (__DEV__) {
  // Shake device or Cmd+D to open menu
  // Select "Show Performance Monitor"
}
```

**Profile with Hermes:**

```typescript
// Take a heap snapshot
const Hermes = global.HermesInternal

if (Hermes) {
  // Enable sampling profiler
  Hermes.enableSamplingProfiler()

  // Later, capture profile
  const profile = Hermes.stopSamplingProfiler()
  console.log('Heap stats:', Hermes.getHeapStatistics())
}
```

**Memory monitoring in CI:**

```typescript
// Add to your app for memory tracking
function useMemoryMonitor() {
  useEffect(() => {
    if (__DEV__) {
      const interval = setInterval(() => {
        if (global.HermesInternal) {
          const stats = global.HermesInternal.getHeapStatistics()
          console.log('Memory:', {
            used: Math.round(stats.heapSize / 1024 / 1024) + 'MB',
            allocated: Math.round(stats.allocatedBytes / 1024 / 1024) + 'MB',
          })
        }
      }, 5000)

      return () => clearInterval(interval)
    }
  }, [])
}
```

**What to look for:**
| Issue | Symptom | Tool |
|-------|---------|------|
| Memory leak | Heap grows over time | Hermes heap snapshot |
| Excessive re-renders | High JS frame time | React Profiler |
| Large objects | Spikes in allocation | Memory timeline |
| Retained views | View count grows | Flipper Layout Inspector |

**Flipper plugins for memory:**
- LeakCanary (Android) - automatic leak detection
- Memory plugin - heap visualization
- React DevTools - component memory

**Pre-release checklist:**
1. Navigate through all screens multiple times
2. Monitor memory for growth
3. Force garbage collection and check for retained objects
4. Test with limited memory (Android emulator settings)

Reference: [React Native DevTools](https://reactnative.dev/docs/react-native-devtools)
