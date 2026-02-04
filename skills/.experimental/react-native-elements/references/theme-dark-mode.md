---
title: Configure Light/Dark Mode with createTheme
impact: CRITICAL
impactDescription: Proper dark mode support across entire app with single configuration
tags: theme, dark-mode, colors, createTheme
---

## Configure Light/Dark Mode with createTheme

Using createTheme with lightColors and darkColors ensures consistent theming across your entire application. Manual color switching in each component leads to inconsistencies, bugs, and unmaintainable code.

**Incorrect (manual color switching in components):**

```tsx
// Bad: Each component handles dark mode independently
const MyComponent = ({ isDarkMode }) => {
  const backgroundColor = isDarkMode ? '#121212' : '#ffffff';
  const textColor = isDarkMode ? '#ffffff' : '#000000';

  return (
    <View style={{ backgroundColor }}>
      <Text style={{ color: textColor }}>Hello</Text>
      <Button
        buttonStyle={{ backgroundColor: isDarkMode ? '#bb86fc' : '#6200ee' }}
      />
    </View>
  );
};
```

**Correct (centralized light/dark configuration in createTheme):**

```tsx
import { createTheme, ThemeProvider } from '@rneui/themed';

// Define theme with both light and dark colors
const theme = createTheme({
  lightColors: {
    primary: '#6200ee',
    background: '#ffffff',
  },
  darkColors: {
    primary: '#bb86fc',
    background: '#121212',
  },
  mode: 'light', // or 'dark'
});

// App-level provider
const App = () => (
  <ThemeProvider theme={theme}>
    <MyApp />
  </ThemeProvider>
);

// Component automatically uses correct colors
const MyComponent = () => {
  const { theme } = useTheme();

  return (
    <View style={{ backgroundColor: theme.colors.background }}>
      <Button color="primary" />
    </View>
  );
};
```

Reference: [React Native Elements Customization](https://reactnativeelements.com/docs/customization)
