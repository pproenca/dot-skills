---
title: Reset Modules When Testing Module State
impact: HIGH
impactDescription: Ensures modules with cached state are properly isolated between tests
tags: setup, modules, vi.resetModules, singletons, module-cache
---

## Reset Modules When Testing Module State

JavaScript modules cache their exports. If a module has internal state (like a singleton or configuration), that state persists across tests. Use `vi.resetModules()` to clear the module cache and get fresh instances.

**Incorrect (cached module state):**

```typescript
import { describe, it, expect, vi } from 'vitest'
import { config } from './config'

describe('Config', () => {
  it('should load default config', () => {
    expect(config.apiUrl).toBe('https://api.example.com')
  })

  it('should allow overrides', () => {
    config.apiUrl = 'https://staging.example.com'
    expect(config.apiUrl).toBe('https://staging.example.com')
  })

  it('should still have default', () => {
    // FAILS - config still has staging URL from previous test
    expect(config.apiUrl).toBe('https://api.example.com')
  })
})
```

**Correct (reset modules between tests):**

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest'

describe('Config', () => {
  beforeEach(() => {
    vi.resetModules()
  })

  it('should load default config', async () => {
    const { config } = await import('./config')
    expect(config.apiUrl).toBe('https://api.example.com')
  })

  it('should allow overrides', async () => {
    const { config } = await import('./config')
    config.apiUrl = 'https://staging.example.com'
    expect(config.apiUrl).toBe('https://staging.example.com')
  })

  it('should still have default', async () => {
    // Works - fresh module instance
    const { config } = await import('./config')
    expect(config.apiUrl).toBe('https://api.example.com')
  })
})
```

**Alternative with vi.doMock:**

```typescript
describe('Config with env vars', () => {
  beforeEach(() => {
    vi.resetModules()
  })

  it('should use production URL', async () => {
    vi.stubEnv('NODE_ENV', 'production')
    const { config } = await import('./config')
    expect(config.apiUrl).toContain('production')
  })

  it('should use development URL', async () => {
    vi.stubEnv('NODE_ENV', 'development')
    const { config } = await import('./config')
    expect(config.apiUrl).toContain('localhost')
  })
})
```

**Benefits:**
- Each test gets fresh module state
- Singletons are properly isolated
- Module-level side effects don't leak

Reference: [Vitest vi.resetModules](https://vitest.dev/api/vi.html#vi-resetmodules)
