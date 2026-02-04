---
title: Use containerStyle for Wrapper Styling
impact: MEDIUM
impactDescription: Ensures proper styling layer separation; avoids conflicts with component internal layout and positioning
tags: style, layout, component-api
---

## Use containerStyle for Wrapper Styling

React Native Elements components have a specific styling hierarchy where containerStyle targets the outer wrapper View. Using the generic style prop or applying wrapper styles to internal elements can conflict with the component's internal layout logic, causing unexpected positioning issues or broken alignments.

**Incorrect (style prop on RNE components):**

```tsx
// Bad: style prop may conflict with internal component structure
function ProfileCard() {
  return (
    <Card
      // Incorrect: Generic style prop - unclear which element receives these styles
      style={{ margin: 16, shadowOpacity: 0.3 }}
    >
      <Card.Title
        // Incorrect: Applying layout styles to title element
        style={{ padding: 20, alignSelf: 'stretch' }}
      >
        Profile
      </Card.Title>
    </Card>
  );
}
```

**Correct (containerStyle for outer wrapper, specific props for internals):**

```tsx
import { Card } from '@rneui/themed';
import { StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  cardContainer: {
    margin: 16,
    shadowOpacity: 0.3,
  },
  titleWrapper: {
    paddingVertical: 10,
  },
});

function ProfileCard() {
  return (
    <Card
      // Good: containerStyle explicitly targets the outer wrapper
      containerStyle={styles.cardContainer}
    >
      <Card.Title
        // Good: Use component's designated wrapper style prop
        containerStyle={styles.titleWrapper}
      >
        Profile
      </Card.Title>
    </Card>
  );
}
```

Reference: [React Native Elements Customization](https://reactnativeelements.com/docs/customization)
