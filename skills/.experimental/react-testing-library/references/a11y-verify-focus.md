---
title: Test Focus Management
impact: LOW
impactDescription: ensures keyboard navigation works correctly
tags: a11y, focus, toHaveFocus, keyboard-navigation
---

## Test Focus Management

Verify focus moves correctly during interactions. Proper focus management is essential for keyboard users.

**Test focus on modal open:**

```tsx
test('focuses first input when modal opens', async () => {
  const user = userEvent.setup()
  render(<ModalTrigger />)

  await user.click(screen.getByRole('button', { name: /open form/i }))

  expect(screen.getByLabelText('Name')).toHaveFocus()
})
```

**Test focus trap in dialogs:**

```tsx
test('traps focus within dialog', async () => {
  const user = userEvent.setup()
  render(<Dialog open>
    <input aria-label="First" />
    <input aria-label="Last" />
    <button>Submit</button>
  </Dialog>)

  // Focus should cycle within dialog
  await user.tab() // First input
  await user.tab() // Last input
  await user.tab() // Submit button
  await user.tab() // Back to first input

  expect(screen.getByLabelText('First')).toHaveFocus()
})
```

**Test focus return on close:**

```tsx
test('returns focus to trigger when modal closes', async () => {
  const user = userEvent.setup()
  render(<ModalWithTrigger />)

  const trigger = screen.getByRole('button', { name: /open/i })
  await user.click(trigger)
  await user.keyboard('{Escape}')

  expect(trigger).toHaveFocus()
})
```

Reference: [WAI-ARIA - Modal Dialog](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/)
