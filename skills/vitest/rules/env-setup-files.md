---
title: Use Setup Files for Global Configuration
impact: MEDIUM
impactDescription: Centralizes test setup and ensures consistent environment across all tests
tags: env, setupFiles, configuration, global-setup, testing-library
---

## Use Setup Files for Global Configuration

Repeating setup code in every test file (like Testing Library matchers, MSW handlers, or global mocks) leads to inconsistency and duplication. Setup files run once before tests and apply to all files.

**Incorrect (repeated setup in each file):**

```typescript
// Every test file has this boilerplate
import '@testing-library/jest-dom'
import { server } from './mocks/server'
import { beforeAll, afterAll, afterEach } from 'vitest'

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

// ...actual tests
```

**Correct (centralized setup file):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    setupFiles: ['./vitest.setup.ts'],
  },
})
```

```typescript
// vitest.setup.ts
import '@testing-library/jest-dom'
import { beforeAll, afterAll, afterEach } from 'vitest'
import { server } from './mocks/server'

// Testing Library matchers
expect.extend(matchers)

// MSW setup
beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

// Global mocks
vi.mock('./config', () => ({
  config: { apiUrl: 'http://localhost:3000' },
}))
```

**Test files become cleaner:**

```typescript
// src/components/UserList.test.tsx
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'

// No boilerplate - just tests
describe('UserList', () => {
  it('should render users', async () => {
    render(<UserList />)
    expect(await screen.findByText('Alice')).toBeInTheDocument()
  })
})
```

**Multiple setup files:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    setupFiles: [
      './vitest.setup.ts',      // Base setup
      './vitest.mocks.ts',      // Global mocks
      './vitest.matchers.ts',   // Custom matchers
    ],
  },
})
```

**Benefits:**
- DRY - setup code in one place
- Consistent environment across all tests
- Easier to update global configuration

Reference: [Vitest Setup Files](https://vitest.dev/config/#setupfiles)
