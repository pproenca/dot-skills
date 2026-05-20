---
title: Use SF Symbols for iconography
impact: CRITICAL
impactDescription: enables 6,900+ system symbols with weight and scale matching
tags: native, sf-symbols, expo-symbols, icons
---

## Use SF Symbols for iconography

SF Symbols are Apple's system icon set: they align to the text baseline, scale with Dynamic Type, match the current font weight, and ship with the exact glyphs users see throughout iOS. Bitmap PNGs or a generic icon font (Material Icons, FontAwesome) sit at a fixed size, ignore weight and Dynamic Type, and look foreign next to the system bars and menus. `expo-symbols` renders the real symbols on iOS and falls back to Material Symbols on Android.

**Incorrect (bitmap or generic icon font):**

```tsx
import { Image } from 'react-native';

// Fixed-size PNG: ignores font weight and Dynamic Type, and ships extra assets
function SaveButton() {
  return <Image source={require('../assets/bookmark.png')} style={{ width: 24, height: 24 }} />;
}
```

**Correct (SF Symbol via expo-symbols):**

```tsx
import { SymbolView } from 'expo-symbols';

// System symbol: matches weight, scales with Dynamic Type, no bundled asset
function SaveButton() {
  return <SymbolView name="bookmark.fill" tintColor="#007aff" size={24} weight="semibold" />;
}
```

Reference: [Expo — Symbols (expo-symbols)](https://docs.expo.dev/versions/latest/sdk/symbols/) · [Apple HIG — SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols)
