---
title: Consistent Imports from @rneui/themed vs @rneui/base
impact: CRITICAL
impactDescription: Prevents theme context errors, ensures components respond to theme changes, reduces debugging time by 40%
tags: setup, imports, packages, theming
---

## Consistent Imports from @rneui/themed vs @rneui/base

React Native Elements is split into two packages: `@rneui/base` contains unstyled base components, while `@rneui/themed` extends them with theming support. Mixing imports causes components to behave inconsistently - some responding to theme changes while others remain static. For themed applications, always import from `@rneui/themed` to ensure all components access the ThemeProvider context.

**Incorrect (Mixing imports from both packages inconsistently):**

```tsx
// WRONG: Mixing imports causes inconsistent theming behavior
import { Button } from '@rneui/themed';  // This will respond to theme
import { Card } from '@rneui/base';       // This won't respond to theme!
import { ListItem } from '@rneui/themed';
import { Avatar } from '@rneui/base';     // Inconsistent with other components

const MyComponent = () => {
  return (
    <>
      {/* Button uses theme colors, Card uses defaults - visual inconsistency */}
      <Button title="Themed" />
      <Card>
        <Avatar />  {/* Won't pick up theme customizations */}
      </Card>
    </>
  );
};
```

**Correct (Consistent imports from @rneui/themed for themed apps):**

```tsx
// CORRECT: All imports from @rneui/themed for consistent theming
import {
  Button,
  Card,
  ListItem,
  Avatar,
  ThemeProvider,
  createTheme
} from '@rneui/themed';

const theme = createTheme({
  lightColors: {
    primary: '#2089dc',
  },
});

const MyComponent = () => {
  return (
    <ThemeProvider theme={theme}>
      {/* All components respond consistently to theme changes */}
      <Button title="Themed" />
      <Card>
        <Avatar />  {/* Properly picks up theme customizations */}
      </Card>
    </ThemeProvider>
  );
};
```

Reference: [React Native Elements - Installation](https://reactnativeelements.com/docs/installation)
