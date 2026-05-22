---
title: Add Web Hover, Focus, and Cursor to Interactive Components
impact: CRITICAL
impactDescription: prevents interactive components from rendering inert on web (no hover, focus, or cursor)
tags: platform, web, hover, cursor
---

## Add Web Hover, Focus, and Cursor to Interactive Components

A button whose only feedback is an `onPressIn` opacity change works on iOS but reads as a dead element on web: the pointer never becomes a hand, hovering does nothing, and keyboard focus shows no ring. Unistyles v3 compiles styles to real CSS classes, so a `_web` block with `_hover`, `_focus`, and `cursor` gives the same component native-feeling pointer affordances on web while leaving the native style untouched.

**Incorrect (touch-only feedback — inert on web):**

```typescript
const styles = StyleSheet.create((theme) => ({
  bookButton: {
    backgroundColor: theme.colors.accent,
    borderRadius: theme.radius.md,
    variants: { pressed: { true: { opacity: 0.7 } } },
  },
}))
// On web the cursor stays an arrow, hover is dead, and Tab focus is invisible.
```

**Correct (web pseudo-states alongside the native style):**

```typescript
const styles = StyleSheet.create((theme) => ({
  bookButton: {
    backgroundColor: theme.colors.accent,
    borderRadius: theme.radius.md,
    variants: { pressed: { true: { opacity: 0.7 } } },
    _web: {
      cursor: 'pointer',
      _hover: { opacity: 0.92 },
      _focus: { outlineColor: theme.colors.accent, outlineStyle: 'solid', outlineWidth: 2 },
    },
  },
}))
// One component now feels native on both: press feedback on iOS, hover/focus/cursor on web.
```

**When NOT to use this pattern:**

- Non-interactive surfaces (cards, non-pressable list rows) — a `cursor: 'pointer'` there misleads web users into clicking.

Reference: [Unistyles web-only features](https://www.unistyl.es/v3/references/web-only/)
