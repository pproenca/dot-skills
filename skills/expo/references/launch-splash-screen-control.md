---
title: Control Splash Screen Visibility During Asset Loading
impact: CRITICAL
impactDescription: prevents white flash and improves perceived startup time
tags: launch, splash-screen, assets, preloading
---

## Control Splash Screen Visibility During Asset Loading

Keep the native splash screen visible while loading critical assets like fonts and images. This prevents the jarring white flash users see when the app renders before assets are ready.

**Incorrect (splash hides before assets load):**

```typescript
import { useEffect, useState } from 'react'
import { View, Text } from 'react-native'

export default function App() {
  const [fontsLoaded, setFontsLoaded] = useState(false)

  useEffect(() => {
    loadFonts().then(() => setFontsLoaded(true))
  }, [])

  if (!fontsLoaded) {
    return null  // White screen while fonts load
  }

  return <HomeScreen />
}
```

**Correct (splash stays until assets ready):**

```typescript
import { useEffect, useState, useCallback } from 'react'
import { View, Text } from 'react-native'
import * as SplashScreen from 'expo-splash-screen'

SplashScreen.preventAutoHideAsync()

export default function App() {
  const [fontsLoaded, setFontsLoaded] = useState(false)

  useEffect(() => {
    loadFonts().then(() => setFontsLoaded(true))
  }, [])

  const onLayoutRootView = useCallback(async () => {
    if (fontsLoaded) {
      await SplashScreen.hideAsync()
    }
  }, [fontsLoaded])

  if (!fontsLoaded) {
    return null  // Splash screen still visible
  }

  return <HomeScreen onLayout={onLayoutRootView} />
}
```

Reference: [Expo SplashScreen Documentation](https://docs.expo.dev/versions/latest/sdk/splash-screen/)
