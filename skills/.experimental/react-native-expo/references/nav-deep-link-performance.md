---
title: Optimize Deep Link Resolution
impact: MEDIUM
impactDescription: faster app launch from external links
tags: nav, deep-links, expo-router, linking, startup
---

## Optimize Deep Link Resolution

Deep links should resolve quickly to the correct screen. Slow resolution delays app launch from external sources.

**Incorrect (blocking initial render on deep link):**

```tsx
// app/_layout.tsx
export default function RootLayout() {
  const [isReady, setIsReady] = useState(false)

  useEffect(() => {
    // Blocking async work before handling deep link
    async function init() {
      await loadUserData()
      await checkPermissions()
      await fetchConfig()
      setIsReady(true)
    }
    init()
  }, [])

  if (!isReady) return <SplashScreen />

  return <Stack />  // Deep link waits for all init
}
```

**Correct (minimal blocking, parallel loading):**

```tsx
// app/_layout.tsx
export default function RootLayout() {
  const [isMinimalReady, setIsMinimalReady] = useState(false)

  useEffect(() => {
    // Only wait for critical auth check
    async function init() {
      await checkAuth()  // Minimal blocking
      setIsMinimalReady(true)
    }
    init()
  }, [])

  if (!isMinimalReady) return <SplashScreen />

  // Let deep link navigate, load other data in background
  return <Stack />
}

// Individual screens load their own data
// app/product/[id].tsx
export default function ProductScreen() {
  const { id } = useLocalSearchParams()

  // Load product-specific data after navigation
  const { data } = useQuery(['product', id], () => fetchProduct(id))

  return <ProductContent product={data} />
}
```

**Configure linking properly:**

```json
// app.json - proper deep link configuration
{
  "expo": {
    "scheme": "myapp",
    "ios": {
      "associatedDomains": ["applinks:example.com"]
    },
    "android": {
      "intentFilters": [
        {
          "action": "VIEW",
          "data": [
            { "scheme": "https", "host": "example.com", "pathPrefix": "/" }
          ],
          "category": ["BROWSABLE", "DEFAULT"]
        }
      ]
    }
  }
}
```

**Handle invalid deep links gracefully:**

```tsx
// app/[...missing].tsx - catch-all for invalid routes
import { Redirect } from 'expo-router'

export default function MissingRoute() {
  // Redirect invalid deep links to home
  return <Redirect href="/" />
}
```

**Test deep link performance:**

```bash
# iOS Simulator
xcrun simctl openurl booted "myapp://product/123"

# Android Emulator
adb shell am start -a android.intent.action.VIEW \
  -d "myapp://product/123" com.example.myapp

# Measure time from link tap to screen render
```

**Benefits:**
- Faster launch from notifications
- Better marketing campaign tracking
- Improved user experience from shared links

Reference: [Expo Router Linking](https://docs.expo.dev/router/reference/linking/)
