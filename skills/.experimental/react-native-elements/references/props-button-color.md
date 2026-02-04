---
title: Use Color Prop for Semantic Button Colors
impact: MEDIUM-HIGH
impactDescription: ensures WCAG contrast compliance with automatic dark mode adaptation
tags: props, buttons, theming, colors, accessibility
---

## Use Color Prop for Semantic Button Colors

The Button component's color prop provides semantic color options (primary, secondary, success, warning, error) that integrate with your theme and ensure proper contrast ratios. Overriding colors with custom buttonStyle breaks theme consistency, loses semantic meaning, and may result in accessibility issues with contrast ratios.

**Incorrect (custom buttonStyle overriding colors):**

```tsx
// Bad: Hardcoded colors that don't respect theme
const BadButtons = () => (
  <View>
    <Button
      title="Submit"
      buttonStyle={{ backgroundColor: '#2089dc' }}
    />
    <Button
      title="Delete"
      buttonStyle={{ backgroundColor: '#ff0000' }}
    />
    <Button
      title="Cancel"
      buttonStyle={{ backgroundColor: '#808080' }}
    />
  </View>
);

// Bad: Inconsistent color usage across the app
const FormButtons = () => (
  <View>
    <Button
      title="Save"
      buttonStyle={{ backgroundColor: '#28a745' }}
    />
    {/* Another screen uses different green */}
    <Button
      title="Confirm"
      buttonStyle={{ backgroundColor: '#4CAF50' }}
    />
  </View>
);

// Bad: Manual dark mode color handling
const ManualDarkMode = ({ isDarkMode }) => (
  <Button
    title="Action"
    buttonStyle={{
      backgroundColor: isDarkMode ? '#1a5276' : '#2089dc',
    }}
    titleStyle={{
      color: isDarkMode ? '#ffffff' : '#ffffff',
    }}
  />
);
```

**Correct (Button color prop):**

```tsx
import { Button, createTheme, ThemeProvider } from '@rneui/themed';

// Good: Semantic color prop
const SemanticButtons = () => (
  <View>
    <Button title="Submit" color="primary" />
    <Button title="Learn More" color="secondary" />
    <Button title="Save" color="success" />
    <Button title="Proceed" color="warning" />
    <Button title="Delete" color="error" />
  </View>
);

// Good: Define semantic colors in theme
const theme = createTheme({
  lightColors: {
    primary: '#2089dc',
    secondary: '#6c757d',
    success: '#28a745',
    warning: '#ffc107',
    error: '#dc3545',
  },
  darkColors: {
    primary: '#4dabf7',
    secondary: '#adb5bd',
    success: '#51cf66',
    warning: '#ffd43b',
    error: '#ff6b6b',
  },
});

// Buttons automatically adapt to dark mode
const ThemedApp = () => (
  <ThemeProvider theme={theme}>
    <Button title="Primary Action" color="primary" />
    <Button title="Danger" color="error" />
  </ThemeProvider>
);

// Good: Combine color prop with type variants
const ButtonVariants = () => (
  <View>
    {/* Solid with semantic color */}
    <Button title="Save" type="solid" color="success" />

    {/* Outline inherits color for border and text */}
    <Button title="Edit" type="outline" color="primary" />

    {/* Clear uses color for text */}
    <Button title="Cancel" type="clear" color="secondary" />

    {/* Error variants */}
    <Button title="Delete" type="solid" color="error" />
    <Button title="Remove" type="outline" color="error" />
  </View>
);

// Good: Custom color when needed, but still theme-integrated
const CustomColorButton = () => {
  const { theme } = useTheme();

  return (
    <Button
      title="Special Action"
      buttonStyle={{
        backgroundColor: theme.colors.primary,
        borderRadius: 20,
      }}
    />
  );
};
```

Reference: [React Native Elements Button](https://reactnativeelements.com/docs/components/button)
