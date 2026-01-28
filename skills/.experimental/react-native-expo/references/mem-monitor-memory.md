---
title: Monitor Memory Usage in Development
impact: LOW-MEDIUM
impactDescription: catches leaks before production, prevents 10-50% memory growth
tags: mem, monitoring, debugging, profiling, devtools
---

## Monitor Memory Usage in Development

Proactive memory monitoring catches leaks early. Use React Native's built-in tools and Chrome DevTools.

**Incorrect (no memory monitoring):**

```tsx
function App() {
  // No monitoring in place
  // Leaks go unnoticed until crash
  return (
    <NavigationContainer>
      <MainStack />
    </NavigationContainer>
  )
}

// Symptoms appear only in production:
// - App gets slower over time
// - Random crashes on low-memory devices
// - Users report "app gets heavy"
```

**Correct (proactive memory monitoring):**

```tsx
import { useEffect, useState } from 'react'
import { AppState } from 'react-native'

function App() {
  useEffect(() => {
    // Listen for memory warnings
    const subscription = AppState.addEventListener('memoryWarning', () => {
      console.warn('Memory warning received!')
      // Clear caches, reduce data
      clearImageCache()
      reduceListData()
    })

    return () => subscription.remove()
  }, [])

  return (
    <NavigationContainer>
      <MainStack />
    </NavigationContainer>
  )
}

// Debug helper to track component instances
const instanceCount = new Map<string, number>()

function useTrackInstance(name: string) {
  useEffect(() => {
    if (__DEV__) {
      const count = (instanceCount.get(name) || 0) + 1
      instanceCount.set(name, count)
      console.log(`${name} instances: ${count}`)

      return () => {
        const newCount = instanceCount.get(name)! - 1
        instanceCount.set(name, newCount)
        if (newCount > 0) {
          console.warn(`${name} may have a leak! ${newCount} instances remain`)
        }
      }
    }
  }, [name])
}

// Usage in screens
function ProfileScreen() {
  useTrackInstance('ProfileScreen')
  // ...
}
```

**Enable Performance Monitor:**

```bash
# In development, shake device or press 'd' in terminal
# Select "Show Perf Monitor"
# Shows RAM and JS heap usage in real-time
```

**Profile with Chrome DevTools:**

```bash
# Start Expo and open debugger
npx expo start
# Press 'j' to open debugger

# In Chrome DevTools:
# 1. Open Memory tab
# 2. Take heap snapshot before navigation
# 3. Navigate through app
# 4. Take another snapshot
# 5. Compare to find retained objects
```

**Monitor list memory:**

```tsx
function MonitoredList({ data }) {
  const [memoryWarning, setMemoryWarning] = useState(false)

  useEffect(() => {
    const subscription = AppState.addEventListener('memoryWarning', () => {
      setMemoryWarning(true)
    })
    return () => subscription.remove()
  }, [])

  return (
    <FlatList
      data={memoryWarning ? data.slice(0, 50) : data}
      renderItem={renderItem}
      windowSize={memoryWarning ? 3 : 7}
    />
  )
}
```

**Memory best practices checklist:**
- [ ] Test on low-memory devices
- [ ] Profile before releases
- [ ] Monitor FlatList windowSize
- [ ] Clear image caches appropriately
- [ ] Handle memoryWarning events

Reference: [React Native Profiling](https://reactnative.dev/docs/profiling)
