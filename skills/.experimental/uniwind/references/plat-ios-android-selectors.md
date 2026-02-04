---
title: Use Platform Selectors for iOS/Android Differences
impact: MEDIUM
impactDescription: eliminates Platform.select boilerplate in components
tags: plat, ios, android, selectors, platform
---

## Use Platform Selectors for iOS/Android Differences

Use `ios:` and `android:` prefixes to apply platform-specific styles without JavaScript conditionals.

**Incorrect (JavaScript Platform.select):**

```tsx
import { Platform, View, Text } from 'react-native'

function Card() {
  return (
    <View
      style={Platform.select({
        ios: { shadowColor: '#000', shadowOpacity: 0.1 },
        android: { elevation: 4 },
      })}
      className="bg-card rounded-lg p-4"
    >
      <Text>Content</Text>
    </View>
  )
}
```

**Correct (platform selectors):**

```tsx
function Card() {
  return (
    <View className="
      bg-card rounded-lg p-4
      ios:shadow-md
      android:elevation-4
    ">
      <Text>Content</Text>
    </View>
  )
}
```

**Common platform differences:**

```tsx
// Fonts differ by platform
<Text className="ios:font-sf-pro android:font-roboto">
  Platform-specific font
</Text>

// Padding for status bar
<View className="ios:pt-12 android:pt-8">
  Header content
</View>

// Shadows vs elevation
<View className="ios:shadow-lg android:elevation-8">
  Elevated card
</View>
```

Reference: [Uniwind Supported ClassNames](https://docs.uniwind.dev/class-names)
