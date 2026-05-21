---
title: Bake Accessibility Into the Component Contract
impact: HIGH
impactDescription: prevents inaccessible variants from shipping to clinicians
tags: api, accessibility, a11y, roles
---

## Bake Accessibility Into the Component Contract

When accessibility is left to each call site, the icon-only delete button ships with no screen-reader label because someone forgot. Making the label a required prop and setting the role inside the component means an inaccessible instance cannot compile, so accessibility scales with usage instead of decaying.

**Incorrect (accessibility left to the caller, then forgotten):**

```typescript
type IconButtonProps = { icon: ReactNode; onPress: () => void }

function IconButton({ icon, onPress }: IconButtonProps) {
  return <Pressable onPress={onPress}>{icon}</Pressable>
}

// VoiceOver announces nothing; the caller was supposed to remember a label:
<IconButton icon={<TrashIcon />} onPress={deleteNote} /> // unusable with a screen reader
```

**Correct (the contract requires an accessibility label):**

```typescript
type IconButtonProps = { icon: ReactNode; onPress: () => void; accessibilityLabel: string }

function IconButton({ icon, onPress, accessibilityLabel }: IconButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      accessibilityLabel={accessibilityLabel}
      hitSlop={8}
    >
      {icon}
    </Pressable>
  )
}
// accessibilityLabel is required, so a delete button cannot ship without an announcement:
<IconButton icon={<TrashIcon />} onPress={deleteNote} accessibilityLabel="Delete note" />
```

Reference: [React Native accessibility](https://reactnative.dev/docs/accessibility)
