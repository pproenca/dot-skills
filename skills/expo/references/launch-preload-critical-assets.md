---
title: Preload Critical Assets During Splash Screen
impact: CRITICAL
impactDescription: eliminates asset loading delays after app renders
tags: launch, assets, preloading, fonts, images
---

## Preload Critical Assets During Splash Screen

Load fonts, icons, and critical images while the splash screen is visible. This ensures assets are ready when the first screen renders, avoiding layout shifts and missing content.

**Incorrect (assets load after render):**

```typescript
import { useEffect, useState } from 'react'
import { Image, View } from 'react-native'

export default function ProfileScreen() {
  const [profile, setProfile] = useState(null)

  useEffect(() => {
    fetchProfile().then(setProfile)
  }, [])

  return (
    <View>
      <Image source={{ uri: profile?.avatarUrl }} />  {/* Loads on demand */}
    </View>
  )
}
```

**Correct (critical assets preloaded):**

```typescript
import { useEffect, useState, useCallback } from 'react'
import { Image, View } from 'react-native'
import * as SplashScreen from 'expo-splash-screen'
import * as Font from 'expo-font'
import { Asset } from 'expo-asset'

SplashScreen.preventAutoHideAsync()

async function loadResourcesAsync() {
  await Promise.all([
    Font.loadAsync({
      'Inter-Bold': require('./assets/fonts/Inter-Bold.ttf'),
    }),
    Asset.loadAsync([
      require('./assets/images/logo.png'),
      require('./assets/images/placeholder-avatar.png'),
    ]),
  ])
}

export default function App() {
  const [resourcesLoaded, setResourcesLoaded] = useState(false)

  useEffect(() => {
    loadResourcesAsync().then(() => setResourcesLoaded(true))
  }, [])

  const onLayoutRootView = useCallback(async () => {
    if (resourcesLoaded) {
      await SplashScreen.hideAsync()
    }
  }, [resourcesLoaded])

  if (!resourcesLoaded) return null

  return <RootNavigator onLayout={onLayoutRootView} />
}
```

Reference: [Expo Asset Documentation](https://docs.expo.dev/versions/latest/sdk/asset/)
