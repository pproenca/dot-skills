---
title: Avoid Synchronous Storage Reads at Startup
impact: HIGH
impactDescription: 50-200ms savings per read
tags: launch, storage, async-storage, startup, blocking
---

## Avoid Synchronous Storage Reads at Startup

Synchronous storage operations block the JavaScript thread. Use async reads and show loading states or cached values.

**Incorrect (blocking startup with storage reads):**

```tsx
// App.tsx - synchronous MMKV read blocks thread
import { MMKV } from 'react-native-mmkv'

const storage = new MMKV()

export default function App() {
  // Blocks JS thread until read completes
  const theme = storage.getString('theme') || 'light'
  const user = JSON.parse(storage.getString('user') || '{}')
  const settings = JSON.parse(storage.getString('settings') || '{}')

  return <MainApp theme={theme} user={user} settings={settings} />
}
```

**Correct (async loading with defaults):**

```tsx
// App.tsx - async storage read with loading state
import AsyncStorage from '@react-native-async-storage/async-storage'
import { useEffect, useState } from 'react'

const DEFAULT_SETTINGS = {
  theme: 'light',
  notifications: true,
}

export default function App() {
  const [settings, setSettings] = useState(DEFAULT_SETTINGS)
  const [isLoaded, setIsLoaded] = useState(false)

  useEffect(() => {
    async function loadSettings() {
      try {
        const stored = await AsyncStorage.getItem('settings')
        if (stored) {
          setSettings(JSON.parse(stored))
        }
      } finally {
        setIsLoaded(true)
      }
    }
    loadSettings()
  }, [])

  // Render immediately with defaults, update when loaded
  return <MainApp settings={settings} />
}
```

**Alternative (preload during splash):**

```tsx
// App.tsx - load all storage during splash screen
import * as SplashScreen from 'expo-splash-screen'

SplashScreen.preventAutoHideAsync()

export default function App() {
  const [appState, setAppState] = useState(null)

  useEffect(() => {
    async function bootstrap() {
      // Load all storage in parallel during splash
      const [theme, user, settings] = await Promise.all([
        AsyncStorage.getItem('theme'),
        AsyncStorage.getItem('user'),
        AsyncStorage.getItem('settings'),
      ])

      setAppState({
        theme: theme || 'light',
        user: user ? JSON.parse(user) : null,
        settings: settings ? JSON.parse(settings) : {},
      })
    }
    bootstrap()
  }, [])

  useEffect(() => {
    if (appState) {
      SplashScreen.hideAsync()
    }
  }, [appState])

  if (!appState) return null

  return <MainApp {...appState} />
}
```

**Benefits:**
- Non-blocking startup
- Faster time to first render
- Can show content immediately with defaults

Reference: [Expo AsyncStorage Documentation](https://docs.expo.dev/versions/latest/sdk/async-storage/)
