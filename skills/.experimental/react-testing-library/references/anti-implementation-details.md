---
title: Avoid Testing Implementation Details
impact: CRITICAL
impactDescription: prevents 50%+ of false test failures during refactoring
tags: anti, implementation-details, behavior, refactoring
---

## Avoid Testing Implementation Details

Test what users experience, not how it's implemented internally. Implementation detail tests break during refactoring even when behavior is unchanged.

**Incorrect (tests internal state and methods):**

```tsx
import { render } from '@testing-library/react'

test('counter increments', () => {
  const { container } = render(<Counter />)
  const instance = container.firstChild._reactInternals

  expect(instance.memoizedState).toBe(0)
  instance.memoizedProps.onClick()
  expect(instance.memoizedState).toBe(1)
})
// Tests React internals, not user behavior
```

**Correct (tests user-visible behavior):**

```tsx
test('counter increments', async () => {
  render(<Counter />)
  const user = userEvent.setup()

  expect(screen.getByText('Count: 0')).toBeInTheDocument()
  await user.click(screen.getByRole('button', { name: /increment/i }))
  expect(screen.getByText('Count: 1')).toBeInTheDocument()
})
// Tests what user sees and does
```

**Signs you're testing implementation details:**
- Accessing component instance or internal state
- Testing specific hook calls or internal methods
- Using container.querySelector with implementation-specific selectors
- Tests break when refactoring without behavior change

Reference: [Testing Implementation Details](https://kentcdodds.com/blog/testing-implementation-details)
