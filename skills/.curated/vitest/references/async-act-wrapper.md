---
title: Await User Events to Avoid Act Warnings
impact: CRITICAL
impactDescription: Prevents "not wrapped in act(...)" warnings and ensures UI updates complete
tags: async, act, user-events, react-testing-library, state-updates
---

## Await User Events to Avoid Act Warnings

When testing React components, user interactions trigger state updates. Forgetting to await these interactions causes the test to continue before React finishes updating, resulting in "not wrapped in act(...)" warnings and flaky assertions.

**Incorrect (missing await on user event):**

```typescript
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, it, expect } from 'vitest'

describe('Counter', () => {
  it('should increment on click', () => {
    render(<Counter />)
    const button = screen.getByRole('button', { name: /increment/i })

    // Not awaited - test continues before state update
    userEvent.click(button)

    // May fail intermittently - state update not complete
    expect(screen.getByText('Count: 1')).toBeInTheDocument()
  })
})
```

**Correct (awaited user event):**

```typescript
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, it, expect } from 'vitest'

describe('Counter', () => {
  it('should increment on click', async () => {
    const user = userEvent.setup()
    render(<Counter />)
    const button = screen.getByRole('button', { name: /increment/i })

    // Awaited - test waits for all state updates
    await user.click(button)

    expect(screen.getByText('Count: 1')).toBeInTheDocument()
  })
})
```

**Best practice pattern:**

```typescript
import userEvent from '@testing-library/user-event'

describe('Form', () => {
  it('should submit form data', async () => {
    // Setup user instance for proper event handling
    const user = userEvent.setup()
    render(<LoginForm />)

    await user.type(screen.getByLabelText(/email/i), 'test@example.com')
    await user.type(screen.getByLabelText(/password/i), 'password123')
    await user.click(screen.getByRole('button', { name: /submit/i }))

    expect(screen.getByText(/welcome/i)).toBeInTheDocument()
  })
})
```

**Benefits:**
- No act() warnings
- State updates complete before assertions
- Deterministic test behavior

Reference: [Testing Library User Event](https://testing-library.com/docs/user-event/intro)
