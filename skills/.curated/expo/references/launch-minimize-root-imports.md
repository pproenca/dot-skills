---
title: Minimize Imports in Root App Component
impact: HIGH
impactDescription: reduces initial bundle parse time by 100-300ms
tags: launch, imports, code-splitting, lazy-loading
---

## Minimize Imports in Root App Component

The root App component and its imports are parsed synchronously at startup. Move heavy imports to screens that need them and use dynamic imports for non-critical features.

**Incorrect (heavy imports in root):**

```typescript
// App.tsx - all imports parsed at startup
import { NavigationContainer } from '@react-navigation/native'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import HomeScreen from './screens/HomeScreen'
import ProfileScreen from './screens/ProfileScreen'
import SettingsScreen from './screens/SettingsScreen'
import AdminDashboard from './screens/AdminDashboard'
import AnalyticsScreen from './screens/AnalyticsScreen'
import { Chart } from 'react-native-charts-wrapper'  // Heavy library
import { Editor } from '@monaco-editor/react'  // Heavy library

const Stack = createNativeStackNavigator()

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Profile" component={ProfileScreen} />
        {/* ... many more screens */}
      </Stack.Navigator>
    </NavigationContainer>
  )
}
```

**Correct (lazy imports for non-critical screens):**

```typescript
// App.tsx - minimal imports
import { lazy, Suspense } from 'react'
import { NavigationContainer } from '@react-navigation/native'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import HomeScreen from './screens/HomeScreen'
import LoadingScreen from './components/LoadingScreen'

const ProfileScreen = lazy(() => import('./screens/ProfileScreen'))
const SettingsScreen = lazy(() => import('./screens/SettingsScreen'))
const AdminDashboard = lazy(() => import('./screens/AdminDashboard'))

const Stack = createNativeStackNavigator()

export default function App() {
  return (
    <NavigationContainer>
      <Suspense fallback={<LoadingScreen />}>
        <Stack.Navigator>
          <Stack.Screen name="Home" component={HomeScreen} />
          <Stack.Screen name="Profile" component={ProfileScreen} />
          <Stack.Screen name="Settings" component={SettingsScreen} />
          <Stack.Screen name="Admin" component={AdminDashboard} />
        </Stack.Navigator>
      </Suspense>
    </NavigationContainer>
  )
}
```

**Note:** With Hermes and memory-mapped bytecode, the benefit of code splitting is reduced compared to web. Focus on deferring heavy libraries like chart libraries and rich text editors.
