---
title: Configure Splash Screen to Hide After Content Ready
impact: CRITICAL
impactDescription: prevents blank screen, improves perceived startup
tags: launch, splash-screen, expo-splash-screen, ux, startup
---

## Configure Splash Screen to Hide After Content Ready

Keep the splash screen visible until your app's first meaningful content is ready. Hiding it too early shows a blank screen.

**Incorrect (splash hides before content ready):**

```tsx
// App.tsx - no splash screen control
export default function App() {
  const [data, setData] = useState(null)

  useEffect(() => {
    fetchInitialData().then(setData)
  }, [])

  // User sees blank screen while data loads
  if (!data) return null

  return <MainContent data={data} />
}
```

**Correct (splash hidden after content ready):**

```tsx
// App.tsx - controlled splash screen
import * as SplashScreen from 'expo-splash-screen'
import { useCallback, useEffect, useState } from 'react'

// Prevent auto-hide
SplashScreen.preventAutoHideAsync()

export default function App() {
  const [appReady, setAppReady] = useState(false)

  useEffect(() => {
    async function prepare() {
      try {
        // Load fonts, fetch initial data, etc.
        await loadFonts()
        await fetchInitialData()
      } finally {
        setAppReady(true)
      }
    }
    prepare()
  }, [])

  const onLayoutRootView = useCallback(async () => {
    if (appReady) {
      // Hide splash after first render
      await SplashScreen.hideAsync()
    }
  }, [appReady])

  if (!appReady) return null

  return (
    <View onLayout={onLayoutRootView}>
      <MainContent />
    </View>
  )
}
```

**Alternative (with Expo Router):**

```tsx
// app/_layout.tsx
import { SplashScreen, Stack } from 'expo-router'
import { useFonts } from 'expo-font'
import { useEffect } from 'react'

SplashScreen.preventAutoHideAsync()

export default function RootLayout() {
  const [fontsLoaded] = useFonts({
    'CustomFont': require('../assets/fonts/Custom.ttf'),
  })

  useEffect(() => {
    if (fontsLoaded) {
      SplashScreen.hideAsync()
    }
  }, [fontsLoaded])

  if (!fontsLoaded) return null

  return <Stack />
}
```

**Benefits:**
- Smooth visual transition from splash to content
- No jarring blank screens
- User perceives faster startup

Reference: [Expo SplashScreen Documentation](https://docs.expo.dev/versions/latest/sdk/splash-screen/)
