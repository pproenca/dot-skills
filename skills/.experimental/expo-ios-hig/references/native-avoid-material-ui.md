---
title: Avoid Material Design component kits on iOS
impact: CRITICAL
impactDescription: eliminates Android Material chrome on iOS
tags: native, material-design, component-library, fidelity
---

## Avoid Material Design component kits on iOS

Material-first libraries (`react-native-paper`, MUI-style kits) render Android conventions: floating action buttons, ripple feedback, filled text fields with floating labels, bottom navigation with the wrong height, and Roboto-flavored typography. On iOS these read as a port of an Android app. Choose iOS-native primitives — or a platform-adaptive layer — so each platform gets its own conventions instead of one platform's conventions everywhere.

**Incorrect (Material components on iOS):**

```tsx
import { FAB, Card, TextInput } from 'react-native-paper';

// Floating action button, ripple, and floating-label field are Android idioms
function NewTrailForm() {
  return (
    <Card>
      <TextInput label="Trail name" mode="outlined" />
      <FAB icon="plus" onPress={saveTrail} />
    </Card>
  );
}
```

**Correct (iOS-native primitives):**

```tsx
import { View, TextInput, Button } from 'react-native';

// Standard iOS field and a bar button action match platform expectations
function NewTrailForm() {
  return (
    <View style={styles.formGroup}>
      <TextInput placeholder="Trail name" style={styles.field} />
      <Button title="Save" onPress={saveTrail} />
    </View>
  );
}
```

**Alternative (one codebase, two platforms):**

Use `Platform.select` or a platform-adaptive design system so iOS renders iOS controls and Android renders Material — rather than forcing Material onto both.

Reference: [Apple HIG — Designing for iOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios)
