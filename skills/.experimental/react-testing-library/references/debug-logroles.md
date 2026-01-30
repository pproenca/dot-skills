---
title: Use logRoles to Find Available Roles
impact: LOW-MEDIUM
impactDescription: reduces query discovery time by 5-10×
tags: debug, logRoles, roles, accessibility
---

## Use logRoles to Find Available Roles

When unsure which role to use in `getByRole`, use `logRoles()` to see all available roles in the rendered output.

**Incorrect (guessing roles):**

```tsx
test('finds navigation links', () => {
  render(<Navigation />)

  // Guessing roles without knowing what's available
  screen.getByRole('nav')        // Error: no element with role "nav"
  screen.getByRole('menuitem')   // Error: no element with role "menuitem"
  // Trial and error wastes time
})
```

**Correct (discover roles first):**

```tsx
import { logRoles } from '@testing-library/dom'

test('finds navigation links', () => {
  const { container } = render(<Navigation />)

  logRoles(container)
  // Console shows:
  // navigation: <nav />
  // link: <a href="/home" />, <a href="/about" />

  // Now we know the correct roles
  screen.getByRole('navigation')
  screen.getAllByRole('link')
})
```

**Common implicit roles to remember:**
- `<button>` → button
- `<input type="text">` → textbox
- `<input type="checkbox">` → checkbox
- `<select>` → combobox
- `<h1>-<h6>` → heading

Reference: [Testing Library - logRoles](https://testing-library.com/docs/dom-testing-library/api-debugging#logroles)
