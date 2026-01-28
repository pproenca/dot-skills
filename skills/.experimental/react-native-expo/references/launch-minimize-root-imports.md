---
title: Minimize Root-Level Imports
impact: CRITICAL
impactDescription: 100-500ms savings on cold start
tags: launch, imports, startup, code-splitting, lazy-loading
---

## Minimize Root-Level Imports

Every import in your root file executes during app startup. Heavy imports block the first render.

**Incorrect (all imports at root level):**

```tsx
// App.tsx - everything imported upfront
import { Chart } from 'victory-native'          // 200KB
import { Editor } from '@tiptap/react-native'    // 150KB
import { Calendar } from 'react-native-calendars' // 100KB
import { Camera } from 'expo-camera'              // Native module init
import { MapView } from 'react-native-maps'       // Heavy native init

export default function App() {
  return (
    <Navigator>
      <HomeScreen />
      <ChartScreen />     {/* Chart only needed here */}
      <EditorScreen />    {/* Editor only needed here */}
    </Navigator>
  )
}
// All modules loaded and initialized at startup
```

**Correct (lazy load heavy modules):**

```tsx
// App.tsx - minimal root imports
import { NavigationContainer } from '@react-navigation/native'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import HomeScreen from './screens/HomeScreen'

const Stack = createNativeStackNavigator()

// Lazy load heavy screens
const ChartScreen = React.lazy(() => import('./screens/ChartScreen'))
const EditorScreen = React.lazy(() => import('./screens/EditorScreen'))

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen
          name="Chart"
          component={ChartScreen}
          options={{ lazy: true }}
        />
        <Stack.Screen
          name="Editor"
          component={EditorScreen}
          options={{ lazy: true }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  )
}
```

**Correct (with Expo Router async routes):**

```tsx
// app/_layout.tsx - Expo Router handles lazy loading
import { Stack } from 'expo-router'

export default function Layout() {
  return <Stack />
}

// app/chart.tsx - only loaded when navigated to
export default function ChartScreen() {
  // Chart imported here, not at root
  const { Chart } = require('victory-native')
  return <Chart />
}
```

**Heavy modules to avoid at root:**
- Chart libraries (victory-native, react-native-charts-wrapper)
- Rich text editors
- Maps (react-native-maps)
- Camera/media libraries
- PDF viewers

Reference: [Expo Async Routes](https://docs.expo.dev/router/reference/async-routes/)
