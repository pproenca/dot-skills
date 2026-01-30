---
title: Use toBeVisible() for User-Perceivable Elements
impact: HIGH
impactDescription: prevents false positives from CSS-hidden elements
tags: assert, toBeVisible, toBeInTheDocument, visibility
---

## Use toBeVisible() for User-Perceivable Elements

`toBeInTheDocument()` only checks DOM presence. `toBeVisible()` verifies the element is actually perceivable by users (not hidden by CSS).

**Incorrect (element in DOM but hidden):**

```tsx
render(
  <div>
    <span style={{ display: 'none' }}>Hidden message</span>
  </div>
)

expect(screen.getByText('Hidden message')).toBeInTheDocument()
// Passes! But user can't see this element
```

**Correct (verify actual visibility):**

```tsx
render(
  <div>
    <span style={{ display: 'none' }}>Hidden message</span>
    <span>Visible message</span>
  </div>
)

expect(screen.getByText('Hidden message')).not.toBeVisible()
expect(screen.getByText('Visible message')).toBeVisible()
// Tests what user actually sees
```

**What toBeVisible() checks:**
- `display: none` (not visible)
- `visibility: hidden` (not visible)
- `opacity: 0` (not visible)
- Element or ancestor hidden
- `hidden` attribute

**When to use toBeInTheDocument():**
- Checking if element was rendered at all
- Testing conditional rendering logic

Reference: [jest-dom - toBeVisible](https://github.com/testing-library/jest-dom#tobevisible)
