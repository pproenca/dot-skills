---
title: Use renderHook for Testing Custom Hooks
impact: LOW-MEDIUM
impactDescription: reduces hook test boilerplate by 50%
tags: setup, renderHook, hooks, testing
---

## Use renderHook for Testing Custom Hooks

Use `renderHook` to test custom hooks in isolation. This is useful for hook libraries, though testing hooks through components is often preferred.

**Incorrect (manual test component):**

```tsx
test('useCounter increments', () => {
  let result
  function CounterWrapper() {
    result = useCounter()
    return null
  }

  render(<CounterWrapper />)
  act(() => result.increment())
  // Awkward pattern, result access is unclear
})
```

**Correct (renderHook):**

```tsx
import { renderHook, act } from '@testing-library/react'

test('useCounter increments', () => {
  const { result } = renderHook(() => useCounter())

  expect(result.current.count).toBe(0)

  act(() => {
    result.current.increment()
  })

  expect(result.current.count).toBe(1)
})
```

**With providers:**

```tsx
const wrapper = ({ children }) => (
  <QueryClientProvider client={queryClient}>
    {children}
  </QueryClientProvider>
)

test('useFetchUser returns user', async () => {
  const { result } = renderHook(() => useFetchUser('123'), { wrapper })

  await waitFor(() => {
    expect(result.current.data).toEqual({ name: 'John' })
  })
})
```

**When to prefer component testing:**
- Hook is tightly coupled to specific UI
- Testing user-visible behavior is more valuable

Reference: [Testing Library - renderHook](https://testing-library.com/docs/react-testing-library/api#renderhook)
