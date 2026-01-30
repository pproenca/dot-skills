---
title: Use name Option with getByRole
impact: CRITICAL
impactDescription: prevents test failures when element order changes
tags: query, getByRole, name, accessible-name
---

## Use name Option with getByRole

When multiple elements share the same role, use the `name` option to filter by accessible name. This prevents brittle tests that break when element order changes.

**Incorrect (relies on element order):**

```tsx
render(
  <nav>
    <button>Cancel</button>
    <button>Submit</button>
  </nav>
)

const buttons = screen.getAllByRole('button')
const submitButton = buttons[1]
// Breaks if button order changes
```

**Correct (targets by accessible name):**

```tsx
render(
  <nav>
    <button>Cancel</button>
    <button>Submit</button>
  </nav>
)

const submitButton = screen.getByRole('button', { name: /submit/i })
// Always finds the right button regardless of order
```

**Tip:** Use regex with `/i` flag for case-insensitive matching:

```tsx
screen.getByRole('heading', { name: /welcome/i })
```

Reference: [Testing Library - getByRole name option](https://testing-library.com/docs/queries/byrole#name)
