---
title: Handle Platform-Specific Props
impact: LOW
impactDescription: matches platform design guidelines, improves perceived quality
tags: adv, platform, ios, android, cross-platform
---

## Handle Platform-Specific Props

iOS and Android have different design languages and user expectations. Using Platform.select allows you to configure RNE components with platform-appropriate props, delivering native-feeling experiences on both platforms without maintaining separate component trees.

**Incorrect (same props for both platforms):**

```tsx
import { Button, SearchBar } from '@rneui/themed';

// Bad: iOS-style elevation looks wrong on Android
const MyButton = () => (
  <Button
    title="Submit"
    raised
    // Same shadow/elevation for both platforms
    containerStyle={{
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.25,
      elevation: 5,
    }}
  />
);

// Bad: Generic SearchBar ignores platform conventions
const MySearch = () => (
  <SearchBar
    placeholder="Search..."
    // No platform prop - uses default which may not match OS
  />
);
```

**Correct (platform-specific configuration):**

```tsx
import { Platform } from 'react-native';
import { Button, SearchBar } from '@rneui/themed';

// Good: Platform-appropriate styling
const MyButton = () => (
  <Button
    title="Submit"
    raised
    containerStyle={Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
      },
      android: {
        elevation: 5,
      },
    })}
    // Platform-specific button radius
    buttonStyle={{
      borderRadius: Platform.select({ ios: 8, android: 4 }),
    }}
  />
);

// Good: SearchBar respects platform design language
const MySearch = () => (
  <SearchBar
    placeholder="Search..."
    platform={Platform.OS === 'ios' ? 'ios' : 'android'}
    // Platform-specific cancel button behavior
    showCancel={Platform.OS === 'ios'}
    cancelButtonTitle="Cancel"
  />
);
```

Reference: [React Native Elements SearchBar](https://reactnativeelements.com/docs/components/searchbar)
