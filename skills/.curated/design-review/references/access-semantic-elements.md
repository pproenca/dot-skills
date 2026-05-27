---
title: Use semantic elements for interactive controls
tags: access, semantics, keyboard
---

## Use semantic elements for interactive controls

A `<div>` with an `onClick` looks clickable but is invisible to assistive tech and unreachable by keyboard — it has no role, no focusability, and no Enter/Space handling. Use the real element (`<button>`, `<a>`, `<nav>`) and inherit those behaviours instead of re-implementing them.

**Incorrect (a div pretending to be a button):**

```tsx
<div className="button" onClick={deleteAccount}>Delete account</div>
```

**Correct (a real button — focusable, keyboard-operable, announced):**

```tsx
<button type="button" className="button" onClick={deleteAccount}>
  Delete account
</button>
```

Reference: [MDN — The Button element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button)
