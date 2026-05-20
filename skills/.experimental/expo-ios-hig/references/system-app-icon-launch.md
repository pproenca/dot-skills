---
title: Configure a real app icon and launch screen
impact: LOW-MEDIUM
impactDescription: prevents shipping the placeholder icon and splash
tags: system, app-icon, splash-screen, launch
---

## Configure a real app icon and launch screen

The icon and the launch screen are the first and last things a user sees each session, and the Expo defaults — a blank icon and a white flash — read as unfinished. The launch screen should match the app's first screen so the transition feels instant rather than like a loading gate. Configure the icon in `app.json` and the splash through the `expo-splash-screen` config plugin (the top-level `splash` key is now legacy), then hold the splash at runtime until your first data is ready.

**Incorrect (rely on the defaults):**

```json
{
  "expo": {
    "name": "Trailhead"
  }
}
```

**Correct (icon plus the expo-splash-screen plugin):**

```json
{
  "expo": {
    "name": "Trailhead",
    "icon": "./assets/icon.png",
    "plugins": [
      ["expo-splash-screen", { "image": "./assets/splash.png", "resizeMode": "contain", "backgroundColor": "#0b3d2e" }]
    ]
  }
}
```

To avoid a flash of empty content, keep the splash visible until the first screen's data resolves:

```tsx
import * as SplashScreen from 'expo-splash-screen';

// Hold the splash, then hide it once the first screen is ready to render
SplashScreen.preventAutoHideAsync();
async function onTrailsReady() {
  await SplashScreen.hideAsync();
}
```

Reference: [Expo — Splash screen and app icon](https://docs.expo.dev/develop/user-interface/splash-screen-and-app-icon/)
