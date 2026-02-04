---
title: Configure SafeAreaProvider for Notched Devices
impact: CRITICAL
impactDescription: Prevents UI cutoff on notched devices (iPhone X+, Android with notches), affects 70%+ of modern devices
tags: setup, safe-area, notch, layout, configuration
---

## Configure SafeAreaProvider for Notched Devices

SafeAreaProvider is a required peer dependency for React Native Elements. Without it, components like BottomSheet, Header, and others cannot properly calculate safe area insets, causing UI elements to be obscured by device notches, status bars, or home indicators. This affects the majority of modern smartphones and leads to poor user experience on flagship devices.

**Incorrect (Missing SafeAreaProvider wrapper):**

```tsx
import { ThemeProvider, createTheme, Header, BottomSheet } from '@rneui/themed';
import { View } from 'react-native';

const theme = createTheme({});

// WRONG: Missing SafeAreaProvider
const App = () => {
  return (
    <ThemeProvider theme={theme}>
      <View style={{ flex: 1 }}>
        {/* Header will be covered by device notch/status bar */}
        <Header centerComponent={{ text: 'My App' }} />

        {/* BottomSheet may be hidden behind home indicator */}
        <BottomSheet isVisible={true}>
          {/* Content */}
        </BottomSheet>
      </View>
    </ThemeProvider>
  );
};
```

**Correct (SafeAreaProvider at app root with proper configuration):**

```tsx
import { ThemeProvider, createTheme, Header, BottomSheet } from '@rneui/themed';
import { SafeAreaProvider, initialWindowMetrics } from 'react-native-safe-area-context';
import { View } from 'react-native';

const theme = createTheme({});

// CORRECT: SafeAreaProvider wraps the entire app at the root
const App = () => {
  return (
    // initialWindowMetrics improves initial render on iOS
    <SafeAreaProvider initialMetrics={initialWindowMetrics}>
      <ThemeProvider theme={theme}>
        <View style={{ flex: 1 }}>
          {/* Header properly respects notch and status bar */}
          <Header centerComponent={{ text: 'My App' }} />

          {/* BottomSheet respects home indicator */}
          <BottomSheet isVisible={true}>
            {/* Content */}
          </BottomSheet>
        </View>
      </ThemeProvider>
    </SafeAreaProvider>
  );
};

export default App;
```

Reference: [React Native Elements - Installation](https://reactnativeelements.com/docs/installation)
