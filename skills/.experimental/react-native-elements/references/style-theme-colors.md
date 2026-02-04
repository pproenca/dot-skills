---
title: Use Theme Colors Over Hardcoded Values
impact: MEDIUM
impactDescription: Enables automatic dark mode support and ensures consistent color palette across the app; reduces maintenance when updating brand colors
tags: style, theming, dark-mode, maintainability
---

## Use Theme Colors Over Hardcoded Values

Hardcoding hex colors in StyleSheet creates maintenance burden and breaks dark mode support. React Native Elements' theming system provides semantic color tokens that automatically adapt to light/dark mode and can be updated globally. Using theme colors ensures visual consistency and simplifies future design system changes.

**Incorrect (hardcoded hex colors in StyleSheet):**

```tsx
import { StyleSheet } from 'react-native';

// Bad: Hardcoded colors don't respond to theme changes
const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff', // Won't change in dark mode
  },
  title: {
    color: '#2089dc', // Hardcoded primary - inconsistent if brand changes
  },
  subtitle: {
    color: '#86939e', // Hardcoded grey - unclear semantic meaning
  },
  errorText: {
    color: '#ff190c', // Hardcoded error color
  },
});
```

**Correct (theme.colors from useTheme):**

```tsx
import { StyleSheet } from 'react-native';
import { useTheme, Text } from '@rneui/themed';

function ThemedComponent() {
  const { theme } = useTheme();

  // Good: Dynamic styles using theme colors
  const styles = StyleSheet.create({
    container: {
      backgroundColor: theme.colors.background, // Adapts to dark mode
    },
    title: {
      color: theme.colors.primary, // Consistent with app theme
    },
    subtitle: {
      color: theme.colors.grey3, // Semantic grey scale
    },
    errorText: {
      color: theme.colors.error, // Semantic error color
    },
  });

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Welcome</Text>
      <Text style={styles.subtitle}>Subtitle text</Text>
    </View>
  );
}
```

Reference: [React Native Elements Customization](https://reactnativeelements.com/docs/customization)
