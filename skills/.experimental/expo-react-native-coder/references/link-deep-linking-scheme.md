---
title: Configure Custom URL Scheme for Deep Links
impact: HIGH
impactDescription: enables app opening from external sources
tags: link, deep-linking, scheme, configuration
---

## Configure Custom URL Scheme for Deep Links

Configure a custom URL scheme to enable deep linking from other apps, emails, or websites. With Expo Router, all routes are automatically deep linkable.

**Incorrect (no scheme configured):**

```json
// app.json - missing scheme
{
  "expo": {
    "name": "MyApp"
  }
}
// Deep links like myapp://profile won't work
```

**Correct (scheme configured):**

```json
// app.json
{
  "expo": {
    "name": "MyApp",
    "scheme": "myapp",
    "ios": {
      "bundleIdentifier": "com.company.myapp"
    },
    "android": {
      "package": "com.company.myapp"
    }
  }
}
```

```bash
# Test deep link
npx uri-scheme open "myapp://profile" --ios
npx uri-scheme open "myapp://user/123" --android
```

```typescript
// Handle incoming links programmatically (optional)
import * as Linking from 'expo-linking';
import { useEffect } from 'react';

export default function App() {
  useEffect(() => {
    // Handle app opened via deep link
    const subscription = Linking.addEventListener('url', ({ url }) => {
      console.log('Opened with URL:', url);
      // Expo Router handles navigation automatically
    });

    // Check if app was opened with a URL
    Linking.getInitialURL().then((url) => {
      if (url) console.log('Initial URL:', url);
    });

    return () => subscription.remove();
  }, []);

  return <Stack />;
}
```

**Note:** Expo Router automatically routes incoming URLs to matching screens. No additional configuration needed.

Reference: [Linking into your app - Expo Documentation](https://docs.expo.dev/linking/into-your-app/)
