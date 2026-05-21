---
title: Load Custom Fonts With expo-font Before First Paint
impact: MEDIUM
impactDescription: prevents a font flash on first render
tags: type, fonts, expo-font, loading
---

## Load Custom Fonts With expo-font Before First Paint

Referencing a custom `fontFamily` before the font is registered renders the first frame in the system font, then snaps to the custom font once it loads — a visible flash of unstyled text. Gating the first render on `useFonts` behind the splash screen guarantees text paints in the right font.

**Incorrect (render before fonts are registered):**

```typescript
export default function App() {
  return <RootNavigator /> // renders immediately, before Inter is available
}

const styles = StyleSheet.create(() => ({ title: { fontFamily: 'Inter-SemiBold' } }))
// The first paint uses the system font, then jumps to Inter — a visible flash.
```

**Correct (gate render on useFonts behind the splash):**

```typescript
import { useFonts } from 'expo-font'
import * as SplashScreen from 'expo-splash-screen'

SplashScreen.preventAutoHideAsync()

export default function App() {
  const [loaded] = useFonts({ 'Inter-SemiBold': require('./assets/Inter-SemiBold.ttf') })
  useEffect(() => { if (loaded) SplashScreen.hideAsync() }, [loaded])
  if (!loaded) return null // hold the splash until fonts are ready
  return <RootNavigator />
}
```

Reference: [expo-font useFonts](https://docs.expo.dev/versions/latest/sdk/font/)
