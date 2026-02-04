---
title: Use createTheme for Type-Safe Theme Configuration
impact: CRITICAL
impactDescription: Provides full TypeScript intellisense, catches theme errors at compile time, reduces runtime theme bugs by 90%
tags: setup, theming, typescript, type-safety, createTheme
---

## Use createTheme for Type-Safe Theme Configuration

The `createTheme` function provides type safety and proper merging of theme values with defaults. Using plain objects bypasses TypeScript validation, leading to misspelled color keys, invalid component props, and runtime errors that are difficult to debug. `createTheme` ensures your theme configuration is validated at compile time and properly merged with React Native Elements' default theme.

**Incorrect (Plain object theme without createTheme):**

```tsx
import { ThemeProvider } from '@rneui/themed';

// WRONG: Plain object lacks type safety and proper merging
const theme = {
  colors: {
    primry: '#2089dc',  // Typo won't be caught!
    secondary: '#ca71eb',
  },
  Button: {
    raisedd: true,  // Invalid prop - no compile error!
  },
};

const App = () => {
  return (
    // Theme won't work correctly - missing default values
    <ThemeProvider theme={theme}>
      {/* Components may have undefined colors */}
    </ThemeProvider>
  );
};
```

**Correct (Using createTheme() with lightColors, darkColors, mode):**

```tsx
import { ThemeProvider, createTheme } from '@rneui/themed';

// CORRECT: createTheme provides type safety and merges with defaults
const theme = createTheme({
  lightColors: {
    primary: '#2089dc',     // TypeScript validates color keys
    secondary: '#ca71eb',
    background: '#ffffff',
  },
  darkColors: {
    primary: '#1a1a2e',
    secondary: '#9c27b0',
    background: '#121212',
  },
  mode: 'light',  // Type-checked: only 'light' | 'dark' allowed
  components: {
    Button: {
      raised: true,         // Props are validated
      buttonStyle: {
        borderRadius: 8,
      },
    },
    Text: (props, theme) => ({
      // Access to theme object for dynamic styling
      style: {
        color: theme.colors.grey0,
      },
    }),
  },
});

const App = () => {
  return (
    <ThemeProvider theme={theme}>
      {/* All components properly inherit theme with defaults */}
    </ThemeProvider>
  );
};
```

Reference: [React Native Elements - createTheme](https://reactnativeelements.com/docs/customization/theming)
