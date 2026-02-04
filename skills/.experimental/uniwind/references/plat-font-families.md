---
title: Configure Font Families Without Fallbacks
impact: MEDIUM
impactDescription: React Native requires exact font file names
tags: plat, fonts, typography, configuration
---

## Configure Font Families Without Fallbacks

React Native doesn't support font fallbacks. Specify only the exact font file name, not a stack of fonts.

**Incorrect (web-style font stack):**

```css
@theme {
  --font-family-sans: 'Inter', 'Helvetica', 'Arial', sans-serif;
  /* React Native will fail to find this font! */
}
```

**Correct (exact font file name):**

```css
@theme {
  --font-family-sans: 'Inter-Regular';
  --font-family-sans-medium: 'Inter-Medium';
  --font-family-sans-bold: 'Inter-Bold';
  --font-family-mono: 'FiraCode-Regular';
}
```

**Font weight mapping:**

```css
@theme {
  /* Map Tailwind weights to font files */
  --font-weight-normal: 'Inter-Regular';
  --font-weight-medium: 'Inter-Medium';
  --font-weight-semibold: 'Inter-SemiBold';
  --font-weight-bold: 'Inter-Bold';
}
```

**Usage in components:**

```tsx
// Use font-sans, font-mono etc.
<Text className="font-sans text-base">Regular text</Text>
<Text className="font-sans-medium text-base">Medium weight</Text>
<Text className="font-mono text-sm">Code text</Text>
```

**Loading fonts with Expo:**

```tsx
import { useFonts, Inter_400Regular, Inter_500Medium } from '@expo-google-fonts/inter'

function App() {
  const [fontsLoaded] = useFonts({
    'Inter-Regular': Inter_400Regular,
    'Inter-Medium': Inter_500Medium,
  })

  if (!fontsLoaded) return null
  return <RootNavigator />
}
```

Reference: [Uniwind Migration Guide](https://docs.uniwind.dev/migration-from-nativewind)
