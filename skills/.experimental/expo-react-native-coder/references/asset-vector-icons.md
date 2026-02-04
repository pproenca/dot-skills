---
title: Use @expo/vector-icons for Icon Sets
impact: MEDIUM
impactDescription: provides popular icon libraries out of the box
tags: asset, icons, vector-icons, ui
---

## Use @expo/vector-icons for Icon Sets

Use `@expo/vector-icons` for popular icon sets like Ionicons, MaterialIcons, and FontAwesome. It's included in Expo by default.

**Incorrect (custom SVG icons for common symbols):**

```typescript
// Creating custom SVGs for standard icons
import HomeSvg from '@/assets/icons/home.svg';
import SearchSvg from '@/assets/icons/search.svg';
// Unnecessary work for common icons
```

**Correct (vector icons library):**

```typescript
import { Ionicons, MaterialIcons, FontAwesome } from '@expo/vector-icons';
import { View } from 'react-native';

export default function IconExamples() {
  return (
    <View>
      {/* Ionicons - iOS-style icons */}
      <Ionicons name="home" size={24} color="#333" />
      <Ionicons name="search" size={24} color="#333" />
      <Ionicons name="person" size={24} color="#333" />

      {/* MaterialIcons - Material Design icons */}
      <MaterialIcons name="settings" size={24} color="#333" />
      <MaterialIcons name="delete" size={24} color="#333" />

      {/* FontAwesome */}
      <FontAwesome name="heart" size={24} color="red" />
    </View>
  );
}

// In tab navigator
import { Tabs } from 'expo-router';

export default function TabLayout() {
  return (
    <Tabs>
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="home" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="person" size={size} color={color} />
          ),
        }}
      />
    </Tabs>
  );
}
```

**Browse all icons:** [icons.expo.fyi](https://icons.expo.fyi)

Reference: [Icons - Expo Documentation](https://docs.expo.dev/guides/icons/)
