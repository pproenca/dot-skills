---
title: Use screen.debug() to Inspect DOM
impact: LOW-MEDIUM
impactDescription: reduces debugging time by visualizing actual DOM state
tags: debug, screen.debug, prettyDOM, inspection
---

## Use screen.debug() to Inspect DOM

When tests fail unexpectedly, use `screen.debug()` to see the current DOM state. This reveals what's actually rendered.

**Incorrect (guessing why query fails):**

```tsx
test('shows user profile', async () => {
  render(<UserProfile userId="123" />)

  // Test fails: Unable to find element with text "John Doe"
  expect(screen.getByText('John Doe')).toBeInTheDocument()
  // Why? Is the text different? Is it loading? Is there an error?
})
```

**Correct (inspect DOM state):**

```tsx
test('shows user profile', async () => {
  render(<UserProfile userId="123" />)

  screen.debug()
  // Console shows: <div>Loading...</div>
  // Ah! Need to wait for loading to complete

  expect(await screen.findByText('John Doe')).toBeInTheDocument()
})
```

**Debug specific elements:**

```tsx
const form = screen.getByRole('form')
screen.debug(form)
// Prints only the form element tree
```

**Limit output size:**

```tsx
screen.debug(undefined, 500)
// Print only first 500 characters
```

**Note:** Remove debug statements before committing tests.

Reference: [Testing Library - screen.debug](https://testing-library.com/docs/dom-testing-library/api-debugging#screendebug)
