---
title: Use updateTheme for Runtime Changes
impact: CRITICAL
impactDescription: Enables smooth theme updates without component remounting or state loss
tags: theme, updateTheme, runtime, performance
---

## Use updateTheme for Runtime Changes

The updateTheme function from useTheme allows you to modify theme values at runtime without causing a full re-render or losing component state. Recreating the entire theme object and remounting ThemeProvider causes unnecessary re-renders and can reset component state.

**Incorrect (recreating theme and remounting provider):**

```tsx
// Bad: Recreating theme causes full remount
const App = () => {
  const [themeConfig, setThemeConfig] = useState({
    colors: { primary: '#6200ee' }
  });

  const changePrimaryColor = (color) => {
    // This recreates the entire theme object
    setThemeConfig({
      ...themeConfig,
      colors: { ...themeConfig.colors, primary: color }
    });
  };

  // ThemeProvider remounts all children when theme object changes
  return (
    <ThemeProvider theme={createTheme(themeConfig)}>
      <MyApp onColorChange={changePrimaryColor} />
    </ThemeProvider>
  );
};
```

**Correct (using updateTheme from useTheme hook):**

```tsx
import { createTheme, ThemeProvider, useTheme } from '@rneui/themed';

const theme = createTheme({
  lightColors: {
    primary: '#6200ee',
  },
});

const App = () => (
  <ThemeProvider theme={theme}>
    <MyApp />
  </ThemeProvider>
);

// Child component updates theme without remounting
const ThemeControls = () => {
  const { updateTheme } = useTheme();

  const changePrimaryColor = (color) => {
    // Merges changes into existing theme smoothly
    updateTheme({
      lightColors: {
        primary: color,
      },
    });
  };

  const toggleDarkMode = () => {
    updateTheme((prevTheme) => ({
      mode: prevTheme.mode === 'dark' ? 'light' : 'dark',
    }));
  };

  return (
    <View>
      <Button title="Blue Theme" onPress={() => changePrimaryColor('#2196F3')} />
      <Button title="Toggle Dark Mode" onPress={toggleDarkMode} />
    </View>
  );
};
```

Reference: [React Native Elements Customization](https://reactnativeelements.com/docs/customization)
