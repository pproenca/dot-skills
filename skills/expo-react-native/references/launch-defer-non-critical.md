---
title: Defer Non-Critical Initialization Until After First Render
impact: CRITICAL
impactDescription: reduces Time to Interactive by 200-500ms
tags: launch, defer, initialization, interactionmanager
---

## Defer Non-Critical Initialization Until After First Render

Analytics, crash reporting, and other non-critical services should initialize after the first meaningful render. This prioritizes showing content to the user.

**Incorrect (all initialization blocks startup):**

```typescript
import { useEffect } from 'react'
import * as Analytics from 'expo-analytics'
import * as Sentry from '@sentry/react-native'
import { initializeDatabase } from './database'
import { syncOfflineData } from './sync'

export default function App() {
  useEffect(() => {
    // All of this runs before user sees anything
    Analytics.initialize('key')
    Sentry.init({ dsn: 'dsn' })
    initializeDatabase()
    syncOfflineData()
  }, [])

  return <HomeScreen />
}
```

**Correct (deferred initialization):**

```typescript
import { useEffect } from 'react'
import { InteractionManager } from 'react-native'
import * as Analytics from 'expo-analytics'
import * as Sentry from '@sentry/react-native'
import { initializeDatabase } from './database'
import { syncOfflineData } from './sync'

export default function App() {
  useEffect(() => {
    // Defer non-critical work until after animations complete
    const task = InteractionManager.runAfterInteractions(() => {
      Analytics.initialize('key')
      Sentry.init({ dsn: 'dsn' })
      initializeDatabase()
      syncOfflineData()
    })

    return () => task.cancel()
  }, [])

  return <HomeScreen />
}
```

**Alternative (setTimeout for simple cases):**

```typescript
useEffect(() => {
  const timer = setTimeout(() => {
    Analytics.initialize('key')
  }, 1000)  // Delay 1 second after mount

  return () => clearTimeout(timer)
}, [])
```

Reference: [React Native InteractionManager](https://reactnative.dev/docs/interactionmanager)
