---
title: Configure Splash Screen with app.json
impact: MEDIUM
impactDescription: creates professional app launch experience
tags: asset, splash-screen, branding, configuration
---

## Configure Splash Screen with app.json

Configure the splash screen in app.json with your app icon, background color, and resize mode.

**Incorrect (default/missing splash configuration):**

```json
{
  "expo": {
    "name": "MyApp"
  }
}
// Shows default Expo splash screen
```

**Correct (custom splash screen):**

```json
{
  "expo": {
    "name": "MyApp",
    "splash": {
      "image": "./assets/splash-icon.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "ios": {
      "splash": {
        "image": "./assets/splash-icon.png",
        "resizeMode": "contain",
        "backgroundColor": "#ffffff",
        "dark": {
          "image": "./assets/splash-icon-dark.png",
          "backgroundColor": "#000000"
        }
      }
    },
    "android": {
      "splash": {
        "image": "./assets/splash-icon.png",
        "resizeMode": "contain",
        "backgroundColor": "#ffffff",
        "dark": {
          "image": "./assets/splash-icon-dark.png",
          "backgroundColor": "#000000"
        }
      }
    }
  }
}
```

**Controlling splash visibility:**

```typescript
import { SplashScreen } from 'expo-router';
import { useEffect } from 'react';

// Prevent auto-hide
SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const [appIsReady, setAppIsReady] = useState(false);

  useEffect(() => {
    async function prepare() {
      // Load fonts, fetch initial data, etc.
      await loadFonts();
      await fetchInitialData();
      setAppIsReady(true);
    }
    prepare();
  }, []);

  useEffect(() => {
    if (appIsReady) {
      SplashScreen.hideAsync();
    }
  }, [appIsReady]);

  if (!appIsReady) return null;

  return <Stack />;
}
```

**Requirements:**
- Image: PNG format, 1024x1024 recommended
- Test on preview/production builds (not Expo Go)

Reference: [Splash screen - Expo Documentation](https://docs.expo.dev/develop/user-interface/splash-screen-and-app-icon/)
