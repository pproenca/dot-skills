---
title: Role Queries Double as Accessibility Tests
impact: LOW
impactDescription: verifies accessibility as a side effect of testing
tags: a11y, getByRole, accessibility, implicit-testing
---

## Role Queries Double as Accessibility Tests

Using `getByRole` queries inherently verifies accessibility. If an element lacks proper roles or labels, the query fails—catching accessibility bugs.

**Query failure reveals accessibility issue:**

```tsx
// Component missing accessible name
render(<button><Icon name="close" /></button>)

screen.getByRole('button', { name: /close/i })
// Error: Unable to find an accessible element with the role "button"
// and name "/close/i"

// Fix: Add aria-label
render(<button aria-label="Close"><Icon name="close" /></button>)

screen.getByRole('button', { name: /close/i })
// Passes - button is now accessible
```

**Common accessibility issues caught by role queries:**

```tsx
// Missing label association
render(<input type="text" />)
screen.getByRole('textbox', { name: /email/i })
// Fails - no accessible name

// Fix with label
render(
  <>
    <label htmlFor="email">Email</label>
    <input id="email" type="text" />
  </>
)
screen.getByRole('textbox', { name: /email/i })
// Passes
```

**Testing that elements are accessible:**

```tsx
// If this query works, the element is accessible
const submitButton = screen.getByRole('button', { name: /submit/i })
const emailInput = screen.getByLabelText('Email')
const dialog = screen.getByRole('dialog', { name: /confirm/i })
```

Reference: [Testing Library Guiding Principles](https://testing-library.com/docs/guiding-principles)
