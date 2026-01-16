---
title: Avoid Deeply Nested Navigators
impact: MEDIUM
impactDescription: reduces navigation complexity and memory overhead
tags: nav, nesting, structure, architecture
---

## Avoid Deeply Nested Navigators

Each navigation layer adds overhead. Keep navigation structure flat where possible and avoid nesting navigators more than 2-3 levels deep.

**Incorrect (deeply nested navigators):**

```typescript
// 4+ levels of nesting
function App() {
  return (
    <NavigationContainer>
      <Drawer.Navigator>  {/* Level 1 */}
        <Drawer.Screen name="Main">
          {() => (
            <Tab.Navigator>  {/* Level 2 */}
              <Tab.Screen name="Home">
                {() => (
                  <Stack.Navigator>  {/* Level 3 */}
                    <Stack.Screen name="Feed">
                      {() => (
                        <Stack.Navigator>  {/* Level 4 - excessive */}
                          <Stack.Screen name="Post" component={PostScreen} />
                        </Stack.Navigator>
                      )}
                    </Stack.Screen>
                  </Stack.Navigator>
                )}
              </Tab.Screen>
            </Tab.Navigator>
          )}
        </Drawer.Screen>
      </Drawer.Navigator>
    </NavigationContainer>
  )
}
```

**Correct (flattened structure):**

```typescript
// app/_layout.tsx - Root with tabs
import { Tabs } from 'expo-router'

export default function RootLayout() {
  return (
    <Tabs>
      <Tabs.Screen name="(home)" />
      <Tabs.Screen name="(search)" />
      <Tabs.Screen name="(profile)" />
    </Tabs>
  )
}

// app/(home)/_layout.tsx - Stack within tab
import { Stack } from 'expo-router'

export default function HomeLayout() {
  return (
    <Stack>
      <Stack.Screen name="index" />
      <Stack.Screen name="post/[id]" />
      <Stack.Screen name="user/[id]" />
    </Stack>
  )
}
```

**Use modal presentation instead of nested stacks:**

```typescript
// app/_layout.tsx
import { Stack } from 'expo-router'

export default function RootLayout() {
  return (
    <Stack>
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      <Stack.Screen
        name="modal"
        options={{ presentation: 'modal' }}
      />
      <Stack.Screen
        name="fullscreen"
        options={{ presentation: 'fullScreenModal' }}
      />
    </Stack>
  )
}
```

**Navigation architecture guidelines:**
- Root: Tabs or Drawer (1 level)
- Per-tab: Stack (2 levels total)
- Modals: Separate from tabs (parallel, not nested)
- Maximum recommended: 3 levels

Reference: [Expo Router Navigation Patterns](https://docs.expo.dev/router/basics/common-navigation-patterns/)
