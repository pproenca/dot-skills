---
title: Use Typed App Config with app.config.ts
impact: CRITICAL
impactDescription: enables autocomplete and type checking for config
tags: setup, typescript, app-config, configuration
---

## Use Typed App Config with app.config.ts

Use `app.config.ts` instead of `app.json` for type-safe configuration with autocomplete and compile-time validation.

**Incorrect (no type safety in JSON):**

```json
{
  "expo": {
    "name": "MyApp",
    "slug": "my-app",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "splash": {
      "image": "./assets/splash.png"
    }
  }
}
```

**Correct (typed config with autocomplete):**

```typescript
import { ExpoConfig, ConfigContext } from 'expo/config';

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: 'MyApp',
  slug: 'my-app',
  version: '1.0.0',
  orientation: 'portrait',
  icon: './assets/icon.png',
  splash: {
    image: './assets/splash.png',
    resizeMode: 'contain',
    backgroundColor: '#ffffff',
  },
  ios: {
    bundleIdentifier: 'com.company.myapp',
    supportsTablet: true,
  },
  android: {
    adaptiveIcon: {
      foregroundImage: './assets/adaptive-icon.png',
      backgroundColor: '#ffffff',
    },
    package: 'com.company.myapp',
  },
  plugins: ['expo-router'],
});
```

**Note:** If both `app.config.ts` and `app.config.js` exist, TypeScript takes precedence.

Reference: [Configure with app config - Expo Documentation](https://docs.expo.dev/workflow/configuration/)
