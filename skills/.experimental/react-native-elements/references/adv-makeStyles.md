---
title: Use makeStyles for Theme-Aware Dynamic Styles
impact: LOW
impactDescription: reduces boilerplate by 40-50% and eliminates useMemo dependency bugs
tags: adv, styling, makeStyles, typescript, theme
---

## Use makeStyles for Theme-Aware Dynamic Styles

The makeStyles hook from @rneui/themed provides theme-reactive styles with full TypeScript support and automatic memoization. Manual useTheme + useMemo patterns are verbose, error-prone, and require explicit dependency management. makeStyles handles all of this automatically.

**Incorrect (manual useTheme + useMemo for computed styles):**

```tsx
import { useMemo } from 'react';
import { StyleSheet } from 'react-native';
import { useTheme } from '@rneui/themed';

const ProfileCard = ({ size }: { size: 'small' | 'large' }) => {
  const { theme } = useTheme();

  // Bad: Verbose, manual memoization, easy to miss dependencies
  const styles = useMemo(
    () =>
      StyleSheet.create({
        container: {
          backgroundColor: theme.colors.background,
          padding: size === 'large' ? 20 : 10,
        },
        text: {
          color: theme.colors.primary,
          fontSize: size === 'large' ? 18 : 14,
        },
      }),
    [theme.colors.background, theme.colors.primary, size] // Easy to miss deps
  );

  return (
    <View style={styles.container}>
      <Text style={styles.text}>Hello</Text>
    </View>
  );
};
```

**Correct (makeStyles hook for type-safe theme-aware styles):**

```tsx
import { makeStyles } from '@rneui/themed';
import { View, Text } from 'react-native';

// Good: Styles defined outside component, typed props support
const useStyles = makeStyles((theme, props: { size: 'small' | 'large' }) => ({
  container: {
    backgroundColor: theme.colors.background,
    padding: props.size === 'large' ? 20 : 10,
  },
  text: {
    color: theme.colors.primary,
    fontSize: props.size === 'large' ? 18 : 14,
  },
}));

const ProfileCard = ({ size }: { size: 'small' | 'large' }) => {
  // Good: Automatic memoization, theme reactivity, type inference
  const styles = useStyles({ size });

  return (
    <View style={styles.container}>
      <Text style={styles.text}>Hello</Text>
    </View>
  );
};
```

Reference: [React Native Elements Styles](https://reactnativeelements.com/docs/customization/styles)
