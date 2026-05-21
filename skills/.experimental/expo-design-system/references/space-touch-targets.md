---
title: Size Interactive Targets to at Least 44 Points
impact: HIGH
impactDescription: prevents mis-taps on undersized controls
tags: space, touch-target, accessibility, hitslop
---

## Size Interactive Targets to at Least 44 Points

An icon rendered at 16pt has a 16pt tappable area — well below the 44pt minimum both platforms recommend — so clinicians tapping on the move keep missing it. A touch-target token sets a minimum hit area, and `hitSlop` extends the touch region without changing the visual size.

**Incorrect (tap area equals the small glyph):**

```typescript
<Pressable onPress={removeMedication}>
  <Icon name="delete" size="sm" /> {/* roughly a 16pt tappable area */}
</Pressable>
// A 16pt target is far below 44pt; the button is easy to miss.
```

**Correct (minimum target token plus hitSlop):**

```typescript
const styles = StyleSheet.create((theme) => ({
  iconButton: {
    minWidth: theme.space.touchTarget,   // 44
    minHeight: theme.space.touchTarget,
    alignItems: 'center',
    justifyContent: 'center',
  },
}))

<Pressable style={styles.iconButton} hitSlop={8} onPress={removeMedication}
  accessibilityRole="button" accessibilityLabel="Remove medication">
  <Icon name="delete" size="sm" />
</Pressable>
```

Reference: [React Native accessibility](https://reactnative.dev/docs/accessibility)
