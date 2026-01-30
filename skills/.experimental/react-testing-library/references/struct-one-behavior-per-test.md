---
title: Test One Behavior Per Test
impact: MEDIUM
impactDescription: reduces debugging time from minutes to seconds
tags: struct, single-responsibility, behavior, focused-tests
---

## Test One Behavior Per Test

Each test should verify one specific behavior. Multiple behaviors in one test obscure which behavior failed.

**Incorrect (multiple behaviors):**

```tsx
test('user profile', async () => {
  render(<UserProfile userId="123" />)

  // Behavior 1: Loading state
  expect(screen.getByText('Loading...')).toBeInTheDocument()

  // Behavior 2: Data display
  expect(await screen.findByText('John Doe')).toBeInTheDocument()
  expect(screen.getByText('john@example.com')).toBeInTheDocument()

  // Behavior 3: Edit mode
  const user = userEvent.setup()
  await user.click(screen.getByRole('button', { name: /edit/i }))
  expect(screen.getByLabelText('Name')).toHaveValue('John Doe')
})
// If test fails, which behavior broke?
```

**Correct (focused tests):**

```tsx
test('shows loading state initially', () => {
  render(<UserProfile userId="123" />)
  expect(screen.getByText('Loading...')).toBeInTheDocument()
})

test('displays user data after loading', async () => {
  render(<UserProfile userId="123" />)

  expect(await screen.findByText('John Doe')).toBeInTheDocument()
  expect(screen.getByText('john@example.com')).toBeInTheDocument()
})

test('enters edit mode when edit button clicked', async () => {
  const user = userEvent.setup()
  render(<UserProfile userId="123" />)
  await screen.findByText('John Doe')

  await user.click(screen.getByRole('button', { name: /edit/i }))

  expect(screen.getByLabelText('Name')).toHaveValue('John Doe')
})
```

Reference: [Testing Trophy](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications)
