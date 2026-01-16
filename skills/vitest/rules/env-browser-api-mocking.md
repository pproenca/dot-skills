---
title: Mock Browser APIs Not Available in Test Environment
impact: MEDIUM
impactDescription: Prevents "X is not defined" errors when testing browser-specific code
tags: env, browser-apis, mocking, window, navigator
---

## Mock Browser APIs Not Available in Test Environment

Even with jsdom/happy-dom, some browser APIs are missing or incomplete. Tests fail with "X is not defined" when code uses APIs like `ResizeObserver`, `IntersectionObserver`, or `matchMedia`. Mock these APIs in setup.

**Incorrect (crashes on missing API):**

```typescript
// Component uses ResizeObserver
export function ResponsiveComponent() {
  useEffect(() => {
    const observer = new ResizeObserver(() => {})
    // ResizeObserver is not defined in jsdom!
  }, [])
}
```

**Correct (mock missing APIs):**

```typescript
// vitest.setup.ts
import { vi } from 'vitest'

// ResizeObserver mock
global.ResizeObserver = vi.fn().mockImplementation(() => ({
  observe: vi.fn(),
  unobserve: vi.fn(),
  disconnect: vi.fn(),
}))

// IntersectionObserver mock
global.IntersectionObserver = vi.fn().mockImplementation(() => ({
  observe: vi.fn(),
  unobserve: vi.fn(),
  disconnect: vi.fn(),
  root: null,
  rootMargin: '',
  thresholds: [],
}))

// matchMedia mock
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
})
```

**Commonly missing APIs:**

```typescript
// vitest.setup.ts

// scrollTo
window.scrollTo = vi.fn()

// localStorage (enhanced mock)
const localStorageMock = {
  getItem: vi.fn(),
  setItem: vi.fn(),
  removeItem: vi.fn(),
  clear: vi.fn(),
}
Object.defineProperty(window, 'localStorage', { value: localStorageMock })

// fetch (if not using MSW)
global.fetch = vi.fn()

// crypto.randomUUID
Object.defineProperty(global, 'crypto', {
  value: {
    randomUUID: () => 'test-uuid-1234',
  },
})
```

**Benefits:**
- Tests run without browser API errors
- Predictable mock behavior
- Can verify interactions with browser APIs

Reference: [Vitest Environment Mocking](https://vitest.dev/guide/mocking)
