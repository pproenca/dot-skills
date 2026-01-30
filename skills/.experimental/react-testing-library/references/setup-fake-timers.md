---
title: Configure userEvent with Fake Timers
impact: MEDIUM
impactDescription: prevents test hangs when using fake timers
tags: setup, fake-timers, userEvent, jest
---

## Configure userEvent with Fake Timers

When using Jest's fake timers, configure `userEvent.setup()` with `advanceTimers` to prevent tests from hanging on delays.

**Incorrect (test hangs):**

```tsx
jest.useFakeTimers()

test('shows loading then content', async () => {
  const user = userEvent.setup()
  render(<DelayedContent delay={1000} />)

  await user.click(screen.getByRole('button'))
  // Test hangs! userEvent waits for real time
})
```

**Correct (configure advanceTimers):**

```tsx
jest.useFakeTimers()

test('shows loading then content', async () => {
  const user = userEvent.setup({
    advanceTimers: jest.advanceTimersByTime
  })
  render(<DelayedContent delay={1000} />)

  await user.click(screen.getByRole('button'))
  // userEvent advances fake timers automatically

  expect(screen.getByText('Content loaded')).toBeInTheDocument()
})
```

**With setup in beforeEach:**

```tsx
let user: ReturnType<typeof userEvent.setup>

beforeEach(() => {
  jest.useFakeTimers()
  user = userEvent.setup({
    advanceTimers: jest.advanceTimersByTime
  })
})

afterEach(() => {
  jest.useRealTimers()
})
```

Reference: [userEvent - advanceTimers option](https://testing-library.com/docs/user-event/options#advancetimers)
