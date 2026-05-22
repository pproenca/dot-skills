---
title: Design for Pointer and Touch, Never Hover-Only
impact: HIGH
impactDescription: prevents hover-only actions from being unreachable on touch
tags: platform, web, touch, accessibility
---

## Design for Pointer and Touch, Never Hover-Only

Revealing actions on hover is a web habit that strands touch users: a phone has no hover, so a row whose delete button only appears on `_hover` can never be triggered there. Treat hover as a progressive enhancement layered on an affordance that already works by tap — a visible control, a swipe action, or a long press — and keep the 44pt touch target on every platform.

**Incorrect (delete only reachable by hover):**

```typescript
const styles = StyleSheet.create((theme) => ({
  rowDelete: { opacity: 0, _web: { _hover: { opacity: 1 } } },
}))
// Invisible and unreachable on touch — the action effectively does not exist on a phone.
```

**Correct (always-present affordance, hover as enhancement):**

```typescript
const styles = StyleSheet.create((theme) => ({
  rowDelete: {
    opacity: 1,                            // tappable on touch; pair with swipe-to-delete on native
    minWidth: theme.space.touchTarget,
    minHeight: theme.space.touchTarget,
    _web: { opacity: 0.6, _hover: { opacity: 1 } }, // subtler until hover, but still clickable
  },
}))
```

Reference: [React Native for Web — Interactions](https://necolas.github.io/react-native-web/docs/interactions/)
