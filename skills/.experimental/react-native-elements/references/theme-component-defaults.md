---
title: Set Component Defaults in Theme
impact: CRITICAL
impactDescription: Reduces repetition by 60-80% and ensures visual consistency across app
tags: theme, components, defaults, DRY
---

## Set Component Defaults in Theme

Defining component defaults in your theme configuration eliminates repetitive props and ensures consistent styling throughout your application. Passing the same props to every Button, Input, or other component creates maintenance burden and inconsistency risks.

**Incorrect (repeating props on every component):**

```tsx
// Bad: Same props repeated everywhere
const Screen1 = () => (
  <View>
    <Button
      radius="lg"
      color="primary"
      titleStyle={{ fontWeight: 'bold' }}
    />
    <Input
      inputContainerStyle={{ borderBottomWidth: 2 }}
      labelStyle={{ color: '#666' }}
    />
  </View>
);

const Screen2 = () => (
  <View>
    <Button
      radius="lg"
      color="primary"
      titleStyle={{ fontWeight: 'bold' }}
    />
    <Input
      inputContainerStyle={{ borderBottomWidth: 2 }}
      labelStyle={{ color: '#666' }}
    />
  </View>
);
```

**Correct (setting defaults in createTheme components object):**

```tsx
import { createTheme, ThemeProvider } from '@rneui/themed';

const theme = createTheme({
  components: {
    Button: {
      radius: 'lg',
      color: 'primary',
      titleStyle: {
        fontWeight: 'bold',
      },
    },
    Input: {
      inputContainerStyle: {
        borderBottomWidth: 2,
      },
      labelStyle: {
        color: '#666',
      },
    },
  },
});

// Components automatically inherit defaults
const Screen1 = () => (
  <View>
    <Button title="Submit" />
    <Input label="Email" />
  </View>
);

const Screen2 = () => (
  <View>
    <Button title="Continue" />
    <Input label="Password" />
  </View>
);
```

Reference: [React Native Elements Customization](https://reactnativeelements.com/docs/customization)
