---
title: Use toHaveAccessibleDescription() for Hint Text
impact: MEDIUM
impactDescription: catches 100% of missing aria-describedby associations
tags: assert, accessibility, aria-describedby, description
---

## Use toHaveAccessibleDescription() for Hint Text

Use `toHaveAccessibleDescription()` to verify error messages, help text, and other descriptions are properly associated with form controls.

**Incorrect (tests DOM structure, not accessibility):**

```tsx
render(
  <div>
    <input aria-describedby="hint" />
    <span id="hint">Must be at least 8 characters</span>
  </div>
)

expect(screen.getByText('Must be at least 8 characters')).toBeInTheDocument()
// Doesn't verify the association with input
```

**Correct (tests accessible description):**

```tsx
render(
  <div>
    <label htmlFor="password">Password</label>
    <input id="password" aria-describedby="hint" />
    <span id="hint">Must be at least 8 characters</span>
  </div>
)

expect(screen.getByLabelText('Password')).toHaveAccessibleDescription(
  'Must be at least 8 characters'
)
// Verifies screen readers will announce this description
```

**For error messages:**

```tsx
render(<Input label="Email" error="Invalid email format" />)

expect(screen.getByLabelText('Email')).toHaveAccessibleDescription(
  'Invalid email format'
)
expect(screen.getByLabelText('Email')).toBeInvalid()
```

**Related matchers:**
- `toHaveAccessibleName()` - verifies accessible name (label)
- `toHaveErrorMessage()` - verifies `aria-errormessage` association

Reference: [jest-dom - toHaveAccessibleDescription](https://github.com/testing-library/jest-dom#tohaveaccessibledescription)
