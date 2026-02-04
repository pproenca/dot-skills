---
title: Extend Theme with Custom Colors Safely
impact: CRITICAL
impactDescription: catches 100% of color typos at compile time with full autocomplete
tags: theme, typescript, custom-colors, type-safety
---

## Extend Theme with Custom Colors Safely

Extending the Colors interface with TypeScript declaration merging ensures your custom colors are type-safe and available with autocomplete throughout your application. Adding arbitrary colors without type declarations leads to runtime errors and no IDE support.

**Incorrect (adding colors without type declaration):**

```tsx
// Bad: Custom colors without TypeScript support
const theme = createTheme({
  lightColors: {
    primary: '#6200ee',
    // @ts-ignore - TypeScript doesn't know about brandPurple
    brandPurple: '#9c27b0',
    surfaceVariant: '#e7e0ec',
  },
});

// No autocomplete, potential typos go unnoticed
const BrandCard = () => {
  const { theme } = useTheme();

  // TypeScript error or any type
  return <View style={{ backgroundColor: theme.colors.brandPurple }} />;
};
```

**Correct (extending Colors interface and using in createTheme):**

```tsx
import { createTheme, ThemeProvider, Colors } from '@rneui/themed';

// Extend the Colors interface with custom colors
declare module '@rneui/themed' {
  export interface Colors {
    brandPurple: string;
    surfaceVariant: string;
    onSurfaceVariant: string;
  }
}

// Custom colors are now type-safe
const theme = createTheme({
  lightColors: {
    primary: '#6200ee',
    brandPurple: '#9c27b0',
    surfaceVariant: '#e7e0ec',
    onSurfaceVariant: '#49454f',
  },
  darkColors: {
    primary: '#bb86fc',
    brandPurple: '#ce93d8',
    surfaceVariant: '#49454f',
    onSurfaceVariant: '#cac4d0',
  },
});

// Full TypeScript support with autocomplete
const BrandCard = () => {
  const { theme } = useTheme();

  return (
    <View style={{ backgroundColor: theme.colors.surfaceVariant }}>
      <Text style={{ color: theme.colors.onSurfaceVariant }}>
        Content
      </Text>
      <View style={{ backgroundColor: theme.colors.brandPurple }} />
    </View>
  );
};
```

Reference: [React Native Elements Customization](https://reactnativeelements.com/docs/customization)
