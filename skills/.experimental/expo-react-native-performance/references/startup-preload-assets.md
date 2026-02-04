---
title: Preload Critical Assets During Splash
impact: CRITICAL
impactDescription: eliminates asset loading flicker
tags: startup, assets, preloading, expo-asset
---

## Preload Critical Assets During Splash

Load critical images and fonts while the splash screen is visible. This prevents UI flicker from missing assets and ensures a smooth transition from splash to app.

**Incorrect (assets load after app renders):**

```typescript
// App.tsx
export default function App() {
  return (
    <View>
      {/* Image flickers in after component mounts */}
      <Image source={require('./assets/logo.png')} />
      <Text style={{ fontFamily: 'Inter' }}>Welcome</Text>
    </View>
  );
}
```

**Correct (assets preloaded during splash):**

```typescript
// App.tsx
import * as SplashScreen from 'expo-splash-screen';
import { Asset } from 'expo-asset';
import * as Font from 'expo-font';

SplashScreen.preventAutoHideAsync();

export default function App() {
  const [assetsLoaded, setAssetsLoaded] = useState(false);

  useEffect(() => {
    async function loadAssets() {
      await Promise.all([
        Asset.loadAsync([
          require('./assets/logo.png'),
          require('./assets/background.png'),
        ]),
        Font.loadAsync({
          'Inter': require('./assets/fonts/Inter.ttf'),
        }),
      ]);
      setAssetsLoaded(true);
      await SplashScreen.hideAsync();
    }
    loadAssets();
  }, []);

  if (!assetsLoaded) return null;

  return <MainApp />;
}
```

**Benefits:**
- Zero asset-loading flicker
- Fonts available on first render
- Perceived instant app startup

Reference: [Expo Asset](https://docs.expo.dev/versions/latest/sdk/asset/)
