---
title: Configure Icon Props Correctly
impact: MEDIUM-HIGH
impactDescription: prevents 50% of icon rendering inconsistencies across icon sets
tags: props, icons, theming, accessibility, sizing
---

## Configure Icon Props Correctly

The Icon component requires explicit size and color props for consistent rendering across different icon sets and theme contexts. Without explicit configuration, icons may appear inconsistently sized, use unexpected colors, or lack proper accessibility labels. Always specify size, color (or use theme-aware configuration), and type for predictable icon rendering.

**Incorrect (Icon without explicit configuration):**

```tsx
// Bad: Icon without size - defaults may vary by icon set
const BadIcon = () => (
  <Icon name="home" />
  // Size varies by icon set, color depends on context
);

// Bad: Inconsistent icon sizing across app
const Navigation = () => (
  <View style={styles.nav}>
    <Icon name="home" type="material" />
    <Icon name="search" type="ionicon" />
    <Icon name="user" type="feather" />
    {/* Each icon type has different default sizes! */}
  </View>
);

// Bad: Hardcoded colors that don't respect theme
const ThemedScreen = () => (
  <View>
    <Icon name="settings" type="material" color="#000000" size={24} />
    {/* Won't adapt to dark mode */}
  </View>
);

// Bad: Missing accessibility for interactive icons
const ActionIcon = ({ onPress }) => (
  <Icon name="delete" type="material" onPress={onPress} />
  // No accessible label for screen readers
);
```

**Correct (Icon with proper configuration):**

```tsx
import { Icon, useTheme } from '@rneui/themed';

// Good: Explicit size and color
const GoodIcon = () => (
  <Icon name="home" type="material" size={24} color="#2089dc" />
);

// Good: Consistent sizing across icon sets
const Navigation = () => (
  <View style={styles.nav}>
    <Icon name="home" type="material" size={24} color="#333" />
    <Icon name="search" type="ionicon" size={24} color="#333" />
    <Icon name="user" type="feather" size={24} color="#333" />
  </View>
);

// Good: Theme-aware icon colors
const ThemedIcon = () => {
  const { theme } = useTheme();

  return (
    <Icon
      name="settings"
      type="material"
      size={24}
      color={theme.colors.grey0}
    />
  );
};

// Good: Accessible interactive icons
const ActionIcon = ({ onPress }) => (
  <Icon
    name="delete"
    type="material"
    size={24}
    color="#D32F2F"
    onPress={onPress}
    accessibilityLabel="Delete item"
    accessibilityRole="button"
  />
);

// Good: Icon with container styling
const CircleIcon = () => (
  <Icon
    name="check"
    type="material"
    size={20}
    color="white"
    containerStyle={{
      backgroundColor: '#4CAF50',
      borderRadius: 20,
      padding: 8,
    }}
  />
);

// Good: Define icon defaults in theme
const theme = createTheme({
  components: {
    Icon: {
      size: 24,
      type: 'material',
    },
  },
});

// Icons inherit defaults from theme
const ThemedApp = () => (
  <ThemeProvider theme={theme}>
    <Icon name="home" color="#333" />
    <Icon name="settings" color="#333" />
  </ThemeProvider>
);
```

Reference: [React Native Elements Icon](https://reactnativeelements.com/docs/components/icon)
