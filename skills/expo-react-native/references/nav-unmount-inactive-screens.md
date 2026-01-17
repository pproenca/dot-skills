---
title: Unmount Inactive Tab Screens to Save Memory
impact: MEDIUM-HIGH
impactDescription: reduces memory footprint by releasing inactive screen resources
tags: nav, tabs, unmountOnBlur, memory
---

## Unmount Inactive Tab Screens to Save Memory

By default, tab screens stay mounted when inactive. For memory-heavy screens, enable `unmountOnBlur` to release resources when the user switches tabs.

**Incorrect (all tabs stay mounted):**

```typescript
import { Tabs } from 'expo-router'

export default function TabLayout() {
  return (
    <Tabs>
      <Tabs.Screen name="home" />
      <Tabs.Screen name="map" />  {/* Heavy MapView stays in memory */}
      <Tabs.Screen name="camera" />  {/* Camera stays active */}
      <Tabs.Screen name="profile" />
    </Tabs>
  )
}
// All 4 screens consume memory simultaneously
```

**Correct (heavy screens unmount when inactive):**

```typescript
import { Tabs } from 'expo-router'

export default function TabLayout() {
  return (
    <Tabs>
      <Tabs.Screen name="home" />
      <Tabs.Screen
        name="map"
        options={{ unmountOnBlur: true }}  // Releases MapView memory
      />
      <Tabs.Screen
        name="camera"
        options={{ unmountOnBlur: true }}  // Stops camera when hidden
      />
      <Tabs.Screen name="profile" />
    </Tabs>
  )
}
```

**With React Navigation:**

```typescript
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs'

const Tab = createBottomTabNavigator()

function TabNavigator() {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen
        name="Map"
        component={MapScreen}
        options={{ unmountOnBlur: true }}
      />
      <Tab.Screen
        name="Camera"
        component={CameraScreen}
        options={{ unmountOnBlur: true }}
      />
    </Tab.Navigator>
  )
}
```

**Screens that benefit from unmountOnBlur:**
- Map views (react-native-maps)
- Camera/video screens
- Heavy chart/visualization screens
- WebView screens
- Screens with many images

**Trade-offs:**
- State is lost on unmount (use external state management)
- Slight delay when re-mounting
- Better for memory-constrained devices

Reference: [React Navigation Tab Options](https://reactnavigation.org/docs/bottom-tab-navigator/#unmountonblur)
