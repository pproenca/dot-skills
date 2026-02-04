---
title: Prefer Component-Specific Style Props
impact: MEDIUM
impactDescription: catches 100% of style prop typos at compile time with full autocomplete
tags: style, component-api, type-safety, maintainability
---

## Prefer Component-Specific Style Props

React Native Elements components expose specific style props for each internal element (buttonStyle, titleStyle, iconStyle, etc.). Using a single generic style prop or incorrect prop names bypasses TypeScript checking, loses IDE autocomplete benefits, and can result in styles not being applied to the intended element.

**Incorrect (single style prop for all component styling):**

```tsx
// Bad: Single style object - unclear which element receives which styles
function ActionButton({ label }: Props) {
  return (
    <Button
      title={label}
      icon={{ name: 'check', color: 'white' }}
      // Incorrect: Mixing different element styles in one prop
      style={{
        backgroundColor: '#2089dc',
        borderRadius: 8,
        fontSize: 18,        // This won't work - wrong element
        fontWeight: 'bold',  // This won't work - wrong element
        marginRight: 10,     // Intended for icon - won't work
      }}
    />
  );
}
```

**Correct (buttonStyle, titleStyle, containerStyle, etc.):**

```tsx
import { Button } from '@rneui/themed';
import { StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  container: {
    marginVertical: 8,
  },
  button: {
    backgroundColor: '#2089dc',
    borderRadius: 8,
    paddingVertical: 12,
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  icon: {
    marginRight: 10,
  },
});

function ActionButton({ label }: Props) {
  return (
    <Button
      title={label}
      icon={{ name: 'check', color: 'white' }}
      // Good: Each style prop targets its specific element
      containerStyle={styles.container}  // Outer wrapper
      buttonStyle={styles.button}        // TouchableOpacity/Pressable
      titleStyle={styles.title}          // Text element
      iconContainerStyle={styles.icon}   // Icon wrapper
    />
  );
}
```

Reference: [React Native Elements Customization](https://reactnativeelements.com/docs/customization)
