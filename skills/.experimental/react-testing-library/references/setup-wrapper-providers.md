---
title: Use Wrapper Option for Context Providers
impact: MEDIUM
impactDescription: simplifies setup, enables rerender with providers
tags: setup, wrapper, providers, context
---

## Use Wrapper Option for Context Providers

Use the `wrapper` option in render to provide context. This keeps providers available during `rerender()` and simplifies test setup.

**Incorrect (manual wrapping each test):**

```tsx
test('shows user name', () => {
  render(
    <ThemeProvider>
      <UserProvider>
        <Header />
      </UserProvider>
    </ThemeProvider>
  )
  // Must repeat wrapper on every rerender
})
```

**Correct (wrapper option):**

```tsx
const AllProviders = ({ children }) => (
  <ThemeProvider>
    <UserProvider>
      {children}
    </UserProvider>
  </ThemeProvider>
)

test('shows user name', () => {
  const { rerender } = render(<Header />, { wrapper: AllProviders })

  // Providers persist through rerender
  rerender(<Header showAvatar />)
})
```

**Create a custom render function:**

```tsx
// test-utils.tsx
const customRender = (ui, options) =>
  render(ui, { wrapper: AllProviders, ...options })

export * from '@testing-library/react'
export { customRender as render }
```

Reference: [Testing Library - wrapper option](https://testing-library.com/docs/react-testing-library/api#wrapper)
