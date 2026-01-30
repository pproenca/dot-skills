---
title: Use toHaveValue() for Form Input Assertions
impact: MEDIUM
impactDescription: prevents type coercion bugs in number/select inputs
tags: assert, toHaveValue, forms, inputs
---

## Use toHaveValue() for Form Input Assertions

Use `toHaveValue()` to assert form input values. It handles different input types correctly and provides clear error messages.

**Incorrect (direct value access):**

```tsx
render(<input type="number" defaultValue={42} />)

const input = screen.getByRole('spinbutton')
expect(input.value).toBe(42)
// Fails! input.value is always a string ("42")
```

**Correct (jest-dom matcher):**

```tsx
render(<input type="number" defaultValue={42} />)

const input = screen.getByRole('spinbutton')
expect(input).toHaveValue(42)
// Handles number conversion automatically
```

**Works with various input types:**

```tsx
// Text input
expect(screen.getByLabelText('Name')).toHaveValue('John')

// Number input
expect(screen.getByLabelText('Age')).toHaveValue(25)

// Select
expect(screen.getByLabelText('Country')).toHaveValue('US')

// Textarea
expect(screen.getByLabelText('Bio')).toHaveValue('My bio...')

// Empty input
expect(screen.getByLabelText('Email')).toHaveValue('')
```

**For checkboxes/radio, use toBeChecked():**

```tsx
expect(screen.getByRole('checkbox')).toBeChecked()
expect(screen.getByRole('radio', { name: /yes/i })).toBeChecked()
```

Reference: [jest-dom - toHaveValue](https://github.com/testing-library/jest-dom#tohavevalue)
