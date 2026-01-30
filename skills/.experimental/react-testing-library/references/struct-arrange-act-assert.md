---
title: Follow Arrange-Act-Assert Pattern
impact: MEDIUM
impactDescription: reduces debugging time by 2-3× with clear test structure
tags: struct, arrange-act-assert, organization, readability
---

## Follow Arrange-Act-Assert Pattern

Structure tests with clear Arrange (setup), Act (action), and Assert (verify) phases. This makes tests easier to read and debug.

**Incorrect (mixed phases):**

```tsx
test('submits form', async () => {
  const user = userEvent.setup()
  render(<ContactForm onSubmit={mockSubmit} />)
  expect(screen.getByRole('button')).toBeDisabled()
  await user.type(screen.getByLabelText('Name'), 'John')
  expect(screen.getByRole('button')).toBeEnabled()
  await user.type(screen.getByLabelText('Email'), 'john@example.com')
  await user.click(screen.getByRole('button'))
  expect(mockSubmit).toHaveBeenCalled()
})
// Interleaved actions and assertions are hard to follow
```

**Correct (clear phases):**

```tsx
test('submits form with valid data', async () => {
  // Arrange
  const mockSubmit = jest.fn()
  const user = userEvent.setup()
  render(<ContactForm onSubmit={mockSubmit} />)

  // Act
  await user.type(screen.getByLabelText('Name'), 'John')
  await user.type(screen.getByLabelText('Email'), 'john@example.com')
  await user.click(screen.getByRole('button', { name: /submit/i }))

  // Assert
  expect(mockSubmit).toHaveBeenCalledWith({
    name: 'John',
    email: 'john@example.com'
  })
})
```

**For complex tests, use separate tests for different behaviors:**

```tsx
test('disables submit button when form is empty', () => { /* ... */ })
test('enables submit button when form is valid', () => { /* ... */ })
test('submits form data on button click', () => { /* ... */ })
```

Reference: [Arrange-Act-Assert Pattern](https://wiki.c2.com/?ArrangeActAssert)
