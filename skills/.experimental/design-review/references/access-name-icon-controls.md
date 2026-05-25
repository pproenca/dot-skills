---
title: Give icon-only controls an accessible name
tags: access, aria, labels
---

## Give icon-only controls an accessible name

An icon-only button — a bare close "×" or a trash icon — exposes no text, so a screen reader announces only "button" and the user cannot tell what it does. Add an accessible name with `aria-label`, and hide the decorative icon from the accessibility tree with `aria-hidden`.

```tsx
<button type="button" aria-label="Close dialog" onClick={onClose}>
  <XIcon aria-hidden />
</button>
```

Reference: [MDN — ARIA button role](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Roles/button_role)
