---
title: Avoid render() in beforeEach
impact: MEDIUM
impactDescription: enables different props per test, clearer test setup
tags: struct, beforeEach, render, setup
---

## Avoid render() in beforeEach

Don't call `render()` in `beforeEach`. Each test should explicitly render with its specific props, making test intent clear.

**Incorrect (shared render):**

```tsx
describe('Button', () => {
  beforeEach(() => {
    render(<Button onClick={mockClick}>Click me</Button>)
  })

  test('renders button text', () => {
    expect(screen.getByRole('button')).toHaveTextContent('Click me')
  })

  test('handles disabled state', () => {
    // Can't test disabled - already rendered without disabled prop!
  })
})
```

**Correct (explicit render per test):**

```tsx
describe('Button', () => {
  test('renders button text', () => {
    render(<Button onClick={mockClick}>Click me</Button>)
    expect(screen.getByRole('button')).toHaveTextContent('Click me')
  })

  test('is disabled when disabled prop is true', () => {
    render(<Button onClick={mockClick} disabled>Click me</Button>)
    expect(screen.getByRole('button')).toBeDisabled()
  })

  test('calls onClick when clicked', async () => {
    const handleClick = jest.fn()
    const user = userEvent.setup()
    render(<Button onClick={handleClick}>Click me</Button>)

    await user.click(screen.getByRole('button'))

    expect(handleClick).toHaveBeenCalledTimes(1)
  })
})
```

**Use beforeEach for non-render setup:**

```tsx
beforeEach(() => {
  jest.clearAllMocks()
  // Setup mocks, not component renders
})
```
