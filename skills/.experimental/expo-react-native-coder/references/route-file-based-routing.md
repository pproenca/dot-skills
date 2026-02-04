---
title: Use File-Based Routing with Expo Router
impact: CRITICAL
impactDescription: automatic deep linking and type-safe navigation
tags: route, expo-router, file-based, navigation
---

## Use File-Based Routing with Expo Router

Expo Router uses file-based routing where files in the `app/` directory automatically become routes. Every screen is automatically deep linkable.

**Incorrect (manual route configuration):**

```typescript
// Manual stack configuration without file structure
const Stack = createNativeStackNavigator();

function App() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="Home" component={HomeScreen} />
      <Stack.Screen name="Profile" component={ProfileScreen} />
      <Stack.Screen name="Settings" component={SettingsScreen} />
    </Stack.Navigator>
  );
}
```

**Correct (file-based routes):**

```plaintext
app/
├── _layout.tsx      # Root layout (Stack navigator)
├── index.tsx        # "/" - Home screen
├── profile.tsx      # "/profile" - Profile screen
└── settings.tsx     # "/settings" - Settings screen
```

```typescript
// app/_layout.tsx
import { Stack } from 'expo-router';

export default function RootLayout() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: 'Home' }} />
      <Stack.Screen name="profile" options={{ title: 'Profile' }} />
      <Stack.Screen name="settings" options={{ title: 'Settings' }} />
    </Stack>
  );
}
```

```typescript
// app/index.tsx
import { Link } from 'expo-router';
import { View, Text } from 'react-native';

export default function HomeScreen() {
  return (
    <View>
      <Text>Home Screen</Text>
      <Link href="/profile">Go to Profile</Link>
    </View>
  );
}
```

Reference: [Introduction to Expo Router - Expo Documentation](https://docs.expo.dev/router/introduction/)
