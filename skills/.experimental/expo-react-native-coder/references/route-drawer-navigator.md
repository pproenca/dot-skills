---
title: Configure Drawer Navigator for Side Menu
impact: MEDIUM
impactDescription: reduces navigation code by 50%
tags: route, drawer, navigation, layout
---

## Configure Drawer Navigator for Side Menu

Use the Drawer navigator for apps with a side menu. Requires `react-native-reanimated` and `react-native-gesture-handler`.

**Incorrect (manual drawer implementation):**

```typescript
// Custom drawer with manual animation - complex and error-prone
import { useState } from 'react';
import { View, Animated, Pressable } from 'react-native';

export default function App() {
  const [drawerOpen, setDrawerOpen] = useState(false);
  const translateX = useRef(new Animated.Value(-250)).current;

  const toggleDrawer = () => {
    Animated.timing(translateX, {
      toValue: drawerOpen ? -250 : 0,
      duration: 300,
    }).start();
    setDrawerOpen(!drawerOpen);
  };
  // 50+ more lines of manual drawer logic...
}
```

**Correct (Expo Router Drawer):**

```bash
npx expo install @react-navigation/drawer react-native-reanimated react-native-gesture-handler
```

```typescript
// app/_layout.tsx - Simple drawer setup
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { Drawer } from 'expo-router/drawer';

export default function RootLayout() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <Drawer>
        <Drawer.Screen name="index" options={{ drawerLabel: 'Home', title: 'Home' }} />
        <Drawer.Screen name="settings" options={{ drawerLabel: 'Settings', title: 'Settings' }} />
        <Drawer.Screen name="profile" options={{ drawerLabel: 'Profile', title: 'Profile' }} />
      </Drawer>
    </GestureHandlerRootView>
  );
}
```

```typescript
// app/index.tsx - Open drawer programmatically
import { View, Text, Button } from 'react-native';
import { DrawerActions, useNavigation } from '@react-navigation/native';

export default function HomeScreen() {
  const navigation = useNavigation();
  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Text>Home Screen</Text>
      <Button title="Open Drawer" onPress={() => navigation.dispatch(DrawerActions.openDrawer())} />
    </View>
  );
}
```

Reference: [Drawer - Expo Documentation](https://docs.expo.dev/router/advanced/drawer/)
