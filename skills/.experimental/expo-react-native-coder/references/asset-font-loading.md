---
title: Load Custom Fonts with useFonts Hook
impact: MEDIUM
impactDescription: enables custom typography
tags: asset, fonts, typography, loading
---

## Load Custom Fonts with useFonts Hook

Use the `useFonts` hook from `expo-font` to load custom fonts before rendering text.

**Incorrect (using fonts before loaded):**

```typescript
// Font may not be loaded, causing fallback or error
<Text style={{ fontFamily: 'MyCustomFont' }}>Hello</Text>
```

**Correct (load fonts before rendering):**

```typescript
import { useFonts } from 'expo-font';
import { SplashScreen, Stack } from 'expo-router';
import { useEffect } from 'react';

// Prevent splash from auto-hiding
SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const [fontsLoaded, fontError] = useFonts({
    'Inter-Regular': require('@/assets/fonts/Inter-Regular.otf'),
    'Inter-Bold': require('@/assets/fonts/Inter-Bold.otf'),
    'Inter-Medium': require('@/assets/fonts/Inter-Medium.otf'),
  });

  useEffect(() => {
    if (fontsLoaded || fontError) {
      SplashScreen.hideAsync();
    }
  }, [fontsLoaded, fontError]);

  if (!fontsLoaded && !fontError) {
    return null;  // Splash screen stays visible
  }

  return <Stack />;
}
```

```typescript
// Using loaded fonts in components
import { Text, StyleSheet } from 'react-native';

export function Heading({ children }: { children: string }) {
  return <Text style={styles.heading}>{children}</Text>;
}

const styles = StyleSheet.create({
  heading: {
    fontFamily: 'Inter-Bold',
    fontSize: 24,
  },
});
```

**Alternative: Config plugin (static fonts):**

```json
// app.json - embeds fonts at build time (faster startup)
{
  "expo": {
    "plugins": [
      [
        "expo-font",
        {
          "fonts": ["./assets/fonts/Inter-Regular.otf"]
        }
      ]
    ]
  }
}
```

**Note:** OTF is preferred over TTF (smaller size, better rendering).

Reference: [Fonts - Expo Documentation](https://docs.expo.dev/develop/user-interface/fonts/)
