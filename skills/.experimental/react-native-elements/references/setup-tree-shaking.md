---
title: Enable Proper Tree-Shaking with Direct Imports
impact: CRITICAL
impactDescription: 30-50% bundle size reduction by excluding unused components from the final build
tags: setup, performance, bundle-size, tree-shaking, imports
---

## Enable Proper Tree-Shaking with Direct Imports

When bundle size is critical, using named imports from the package root can include more code than necessary in your bundle. Metro bundler and other bundlers may not always tree-shake effectively from barrel exports. Direct imports from specific component paths guarantee only the required component code is included, potentially reducing bundle size by 30-50% for apps using only a few components.

**Incorrect (Barrel imports may include unused code):**

```tsx
// WRONG for bundle-critical apps: Barrel export may pull in all components
import { Button, Card } from '@rneui/themed';

// Even though we only use Button and Card, the bundler might include
// code for Tooltip, Avatar, ListItem, etc. depending on tree-shaking support

const MyScreen = () => {
  return (
    <>
      <Button title="Submit" />
      <Card>
        <Card.Title>My Card</Card.Title>
      </Card>
    </>
  );
};
```

**Correct (Direct component imports when bundle size is critical):**

```tsx
// CORRECT: Direct imports guarantee minimal bundle size
import Button from '@rneui/themed/dist/Button';
import Card from '@rneui/themed/dist/Card';
import { ThemeProvider, createTheme } from '@rneui/themed';

// Only Button and Card code is included in the bundle
// Other components like Tooltip, Avatar, etc. are excluded

const theme = createTheme({
  lightColors: {
    primary: '#2089dc',
  },
});

const MyScreen = () => {
  return (
    <ThemeProvider theme={theme}>
      <Button title="Submit" />
      <Card>
        <Card.Title>My Card</Card.Title>
      </Card>
    </ThemeProvider>
  );
};

// NOTE: For most apps, the standard import is fine.
// Use direct imports only when bundle analysis shows
// unnecessary code inclusion from @rneui/themed
```

Reference: [React Native Elements - Installation](https://reactnativeelements.com/docs/installation)
