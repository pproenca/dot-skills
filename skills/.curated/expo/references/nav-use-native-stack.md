---
title: Use Native Stack Navigator for Performance
impact: MEDIUM-HIGH
impactDescription: 2× smoother transitions, 30% lower memory per screen
tags: nav, stack, native-stack, expo-router
---

## Use Native Stack Navigator for Performance

Use native stack navigation (UINavigationController on iOS, Fragment on Android) instead of JavaScript-based stack navigators. Native stacks provide smoother transitions and better memory management.

**Incorrect (JavaScript stack navigator):**

```typescript
import { createStackNavigator } from '@react-navigation/stack'

const Stack = createStackNavigator()

function AppNavigator() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="Home" component={HomeScreen} />
      <Stack.Screen name="Profile" component={ProfileScreen} />
    </Stack.Navigator>
  )
}
// JS-based animations, higher memory usage, can drop frames
```

**Correct (native stack navigator):**

```typescript
import { createNativeStackNavigator } from '@react-navigation/native-stack'

const Stack = createNativeStackNavigator()

function AppNavigator() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="Home" component={HomeScreen} />
      <Stack.Screen name="Profile" component={ProfileScreen} />
    </Stack.Navigator>
  )
}
// Native animations, optimal memory, smooth 60fps
```

**With Expo Router (native by default):**

```typescript
// app/_layout.tsx
import { Stack } from 'expo-router'

export default function Layout() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: 'Home' }} />
      <Stack.Screen name="profile" options={{ title: 'Profile' }} />
    </Stack>
  )
}
// Expo Router uses native stack by default
```

**When to use JS stack:**
- Complex custom header animations
- Shared element transitions (use react-native-shared-element-transition)
- Full control over gesture handling

**Benefits of native stack:**
- Native platform animations (iOS swipe-back, Android slide)
- Better memory management (native view lifecycle)
- Consistent behavior with native apps
- Hardware-accelerated transitions

Reference: [Expo Router Stack](https://docs.expo.dev/router/advanced/stack/)
