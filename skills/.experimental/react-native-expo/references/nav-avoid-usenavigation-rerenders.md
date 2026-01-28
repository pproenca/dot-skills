---
title: Avoid useNavigation Re-render Issues
impact: HIGH
impactDescription: prevents re-renders on every route change
tags: nav, useNavigation, re-renders, expo-router, performance
---

## Avoid useNavigation Re-render Issues

`useNavigation` from expo-router can cause components to re-render on every navigation event, even when not active.

**Incorrect (re-renders on every route change):**

```tsx
// components/Header.tsx
import { useNavigation } from 'expo-router'

function Header() {
  // This hook causes re-render on EVERY route change
  const navigation = useNavigation()

  return (
    <View>
      <TouchableOpacity onPress={() => navigation.goBack()}>
        <Text>Back</Text>
      </TouchableOpacity>
    </View>
  )
}
// Component re-renders even when it's on an inactive tab
```

**Correct (use @react-navigation/native):**

```tsx
// components/Header.tsx
import { useNavigation } from '@react-navigation/native'

function Header() {
  // This version doesn't cause spurious re-renders
  const navigation = useNavigation()

  return (
    <View>
      <TouchableOpacity onPress={() => navigation.goBack()}>
        <Text>Back</Text>
      </TouchableOpacity>
    </View>
  )
}
```

**Alternative (use router instead of navigation):**

```tsx
// For simple navigation, use router directly
import { router } from 'expo-router'

function Header() {
  // No hook needed, no re-render issues
  return (
    <View>
      <TouchableOpacity onPress={() => router.back()}>
        <Text>Back</Text>
      </TouchableOpacity>
    </View>
  )
}

// router methods:
router.push('/settings')
router.replace('/home')
router.back()
router.navigate('/profile')
```

**Isolate navigation state subscriptions:**

```tsx
// If you need navigation state, isolate it
function NavigationAwareComponent() {
  return (
    <View>
      <NavigationInfo />  {/* Only this re-renders */}
      <ExpensiveContent />  {/* This stays stable */}
    </View>
  )
}

// Separate component subscribes to navigation
function NavigationInfo() {
  const navigation = useNavigation()
  const state = navigation.getState()
  return <Text>Screen: {state.routes[state.index].name}</Text>
}

// Memoized to prevent parent re-renders from affecting it
const ExpensiveContent = memo(function ExpensiveContent() {
  return <ComplexUI />
})
```

**When you need useNavigation from expo-router:**
- Accessing Expo Router-specific features
- Type-safe navigation in TypeScript
- Using Expo Router's navigation events

Reference: [Expo Router Navigation](https://docs.expo.dev/router/navigating-pages/)
