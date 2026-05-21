---
title: Respect OS Font Scaling in the Type Scale
impact: HIGH
impactDescription: prevents clipped text at large accessibility font sizes
tags: type, accessibility, dynamic-type, scaling
---

## Respect OS Font Scaling in the Type Scale

Disabling `allowFontScaling` and pinning a fixed row height clips text the moment a clinician raises their system font size — an accessibility regression that ships invisibly. Allowing scaling with a sane cap and letting containers grow keeps text legible across the OS font-size range.

**Incorrect (fixed height with scaling turned off):**

```typescript
<View style={{ height: 44 }}>
  <Text allowFontScaling={false} style={{ fontSize: 16 }}>
    {patient.fullName}
  </Text>
</View>
// At large accessibility text sizes the name is clipped, and scaling is off entirely.
```

**Correct (cap the multiplier, let the row grow):**

```typescript
const styles = StyleSheet.create((theme) => ({
  nameRow: { minHeight: theme.space.touchTarget, justifyContent: 'center' },
  name: theme.typography.body,
}))

<View style={styles.nameRow}>
  <Text maxFontSizeMultiplier={1.6} style={styles.name}>
    {patient.fullName}
  </Text>
</View>
// Scaling stays on with a cap, and minHeight lets the row expand instead of clipping.
```

Reference: [React Native accessibility](https://reactnative.dev/docs/accessibility)
