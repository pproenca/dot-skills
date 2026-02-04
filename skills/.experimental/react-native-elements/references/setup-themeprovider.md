---
title: Wrap App with ThemeProvider
impact: CRITICAL
impactDescription: Ensures consistent theming across all components, prevents prop drilling for styles, and enables dark/light mode switching
tags: setup, theming, provider, configuration
---

## Wrap App with ThemeProvider

ThemeProvider is essential for React Native Elements to function correctly with consistent styling. Without it, components lose access to the theme context, requiring manual prop passing for every style customization. This leads to inconsistent UI, duplicated styling code, and inability to implement features like dark mode switching.

**Incorrect (Components without ThemeProvider wrapper):**

```tsx
import { Button, Text } from '@rneui/themed';
import { View } from 'react-native';

// Missing ThemeProvider - components will use default styles only
// No way to customize theme or switch between light/dark modes
const App = () => {
  return (
    <View>
      {/* These components can't access custom theme */}
      <Button title="Click Me" />
      <Text>Hello World</Text>
    </View>
  );
};

export default App;
```

**Correct (App wrapped with ThemeProvider from @rneui/themed):**

```tsx
import { ThemeProvider, Button, Text, createTheme } from '@rneui/themed';
import { View } from 'react-native';

// Create theme configuration
const theme = createTheme({
  lightColors: {
    primary: '#2089dc',
  },
  darkColors: {
    primary: '#121212',
  },
  mode: 'light',
});

// Wrap entire app with ThemeProvider at the root
const App = () => {
  return (
    <ThemeProvider theme={theme}>
      <View>
        {/* All components now have access to theme context */}
        <Button title="Click Me" />
        <Text>Hello World</Text>
      </View>
    </ThemeProvider>
  );
};

export default App;
```

Reference: [React Native Elements - ThemeProvider](https://reactnativeelements.com/docs/customization/theming)
