---
title: Setup userEvent Before Render
impact: HIGH
impactDescription: prevents missed events during component mount
tags: user, userEvent, setup, initialization
---

## Setup userEvent Before Render

Always call `userEvent.setup()` before `render()` to ensure proper initialization. This configures event timing and keyboard state correctly.

**Incorrect (setup after render or direct API):**

```tsx
render(<Modal />)

const user = userEvent.setup()
await user.click(screen.getByRole('button'))
// May miss events that fire during render

// Or using direct API (deprecated pattern):
await userEvent.click(screen.getByRole('button'))
// Less control over timing and options
```

**Correct (setup before render):**

```tsx
const user = userEvent.setup()
render(<Modal />)

await user.click(screen.getByRole('button', { name: /open/i }))
expect(screen.getByRole('dialog')).toBeInTheDocument()
// Properly configured event simulation
```

**Configuring setup options:**

```tsx
const user = userEvent.setup({
  delay: null, // Speed up tests by removing typing delay
  advanceTimers: jest.advanceTimersByTime, // For fake timers
})
```

Reference: [userEvent - Setup](https://testing-library.com/docs/user-event/setup)
