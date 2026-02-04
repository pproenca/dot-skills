---
title: Use StyleSheet.create Over Inline Objects
impact: MEDIUM
impactDescription: Prevents unnecessary re-renders by maintaining stable object references; inline styles create new objects each render
tags: style, performance, optimization
---

## Use StyleSheet.create Over Inline Objects

Inline style objects are recreated on every render, causing React Native to perform unnecessary style comparisons and potentially triggering child re-renders. StyleSheet.create creates static references that remain stable across renders, improving performance and enabling React Native's style caching optimizations.

**Incorrect (inline style objects):**

```tsx
// Bad: Creates new object on every render
function MyComponent() {
  return (
    <Button
      title="Submit"
      // New object created each render - triggers style recalculation
      buttonStyle={{ padding: 10, margin: 5, backgroundColor: '#2089dc' }}
      titleStyle={{ fontSize: 16, fontWeight: 'bold' }}
    />
  );
}
```

**Correct (StyleSheet.create outside component):**

```tsx
import { StyleSheet } from 'react-native';
import { Button } from '@rneui/themed';

// Good: Static references created once at module load
const styles = StyleSheet.create({
  button: {
    padding: 10,
    margin: 5,
    backgroundColor: '#2089dc',
  },
  title: {
    fontSize: 16,
    fontWeight: 'bold',
  },
});

function MyComponent() {
  return (
    <Button
      title="Submit"
      buttonStyle={styles.button}
      titleStyle={styles.title}
    />
  );
}
```

Reference: [React Native Elements Customization](https://reactnativeelements.com/docs/customization)
