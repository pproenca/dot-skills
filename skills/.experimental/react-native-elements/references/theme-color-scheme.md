---
title: Sync with System Color Scheme
impact: CRITICAL
impactDescription: Respects user OS preferences and provides seamless automatic mode switching
tags: theme, color-scheme, system-preferences, accessibility
---

## Sync with System Color Scheme

Syncing your app's theme with the system color scheme respects user preferences and provides a native feel. Ignoring useColorScheme from React Native means users who prefer dark mode will see a jarring light theme, harming user experience and accessibility.

**Incorrect (ignoring system color scheme):**

```tsx
// Bad: Hardcoded mode ignores user preferences
const theme = createTheme({
  mode: 'light', // Always light, even if user prefers dark
});

const App = () => (
  <ThemeProvider theme={theme}>
    <MyApp />
  </ThemeProvider>
);

// Bad: Manual toggle without system sync
const App = () => {
  const [isDark, setIsDark] = useState(false);

  return (
    <ThemeProvider theme={createTheme({ mode: isDark ? 'dark' : 'light' })}>
      <MyApp />
    </ThemeProvider>
  );
};
```

**Correct (useEffect with setMode based on system preference):**

```tsx
import { useColorScheme } from 'react-native';
import { createTheme, ThemeProvider, useTheme } from '@rneui/themed';

const theme = createTheme({
  lightColors: {
    primary: '#6200ee',
  },
  darkColors: {
    primary: '#bb86fc',
  },
});

const App = () => (
  <ThemeProvider theme={theme}>
    <ThemeSync />
    <MyApp />
  </ThemeProvider>
);

// Component that syncs with system preference
const ThemeSync = () => {
  const colorScheme = useColorScheme();
  const { updateTheme } = useTheme();

  useEffect(() => {
    // Automatically switch mode when system preference changes
    updateTheme({ mode: colorScheme === 'dark' ? 'dark' : 'light' });
  }, [colorScheme, updateTheme]);

  return null;
};
```

Reference: [React Native Elements Customization](https://reactnativeelements.com/docs/customization)
