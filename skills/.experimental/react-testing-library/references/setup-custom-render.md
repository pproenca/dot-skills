---
title: Create Custom Render with Providers
impact: MEDIUM
impactDescription: eliminates boilerplate across test files
tags: setup, custom-render, providers, test-utils
---

## Create Custom Render with Providers

Create a custom render function that includes common providers. Export it from a test utilities file to eliminate boilerplate.

**Incorrect (repeated provider setup):**

```tsx
// user.test.tsx
test('displays user', () => {
  render(
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <UserProfile />
      </AuthProvider>
    </QueryClientProvider>
  )
})

// settings.test.tsx - same providers repeated
test('shows settings', () => {
  render(
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <Settings />
      </AuthProvider>
    </QueryClientProvider>
  )
})
```

**Correct (custom render in test-utils):**

```tsx
// test-utils.tsx
import { render } from '@testing-library/react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { AuthProvider } from './auth'

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } }
  })

  return ({ children }) => (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        {children}
      </AuthProvider>
    </QueryClientProvider>
  )
}

const customRender = (ui, options) =>
  render(ui, { wrapper: createWrapper(), ...options })

export * from '@testing-library/react'
export { customRender as render }
```

```tsx
// user.test.tsx
import { render, screen } from './test-utils'

test('displays user', () => {
  render(<UserProfile />)
  // Providers automatically included
})
```

Reference: [Testing Library - Custom Render](https://testing-library.com/docs/react-testing-library/setup#custom-render)
