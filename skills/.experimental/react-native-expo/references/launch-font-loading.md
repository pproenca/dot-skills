---
title: Load Fonts Before Rendering Text
impact: HIGH
impactDescription: prevents text flash and layout shift
tags: launch, fonts, expo-font, ux, loading
---

## Load Fonts Before Rendering Text

Custom fonts must load before rendering text that uses them. Unloaded fonts cause invisible text or layout shifts.

**Incorrect (rendering before fonts load):**

```tsx
// App.tsx - text renders with system font, then shifts
import { Text } from 'react-native'

export default function App() {
  useFonts({
    'CustomFont': require('./assets/fonts/Custom.ttf'),
  })

  // Text flashes from system font to custom font
  return <Text style={{ fontFamily: 'CustomFont' }}>Hello</Text>
}
```

**Correct (wait for fonts before rendering):**

```tsx
// App.tsx - controlled font loading
import { useFonts } from 'expo-font'
import * as SplashScreen from 'expo-splash-screen'
import { useCallback } from 'react'

SplashScreen.preventAutoHideAsync()

export default function App() {
  const [fontsLoaded, fontError] = useFonts({
    'Inter-Regular': require('./assets/fonts/Inter-Regular.ttf'),
    'Inter-Bold': require('./assets/fonts/Inter-Bold.ttf'),
  })

  const onLayoutRootView = useCallback(async () => {
    if (fontsLoaded || fontError) {
      await SplashScreen.hideAsync()
    }
  }, [fontsLoaded, fontError])

  if (!fontsLoaded && !fontError) {
    return null // Splash screen still visible
  }

  return (
    <View style={{ flex: 1 }} onLayout={onLayoutRootView}>
      <Text style={{ fontFamily: 'Inter-Regular' }}>Hello</Text>
    </View>
  )
}
```

**Alternative (embed fonts in native build):**

```json
// app.json - fonts loaded at native level (faster)
{
  "expo": {
    "plugins": [
      [
        "expo-font",
        {
          "fonts": [
            "./assets/fonts/Inter-Regular.ttf",
            "./assets/fonts/Inter-Bold.ttf"
          ]
        }
      ]
    ]
  }
}
```

```tsx
// App.tsx - fonts already available
export default function App() {
  // No useFonts needed - fonts embedded at build time
  return <Text style={{ fontFamily: 'Inter-Regular' }}>Hello</Text>
}
```

**Benefits:**
- No text flashing
- No layout shifts
- Faster perceived load when embedded in native build

Reference: [Expo Font Documentation](https://docs.expo.dev/versions/latest/sdk/font/)
