---
title: Limit E2E Tests to Critical User Paths
impact: LOW
impactDescription: reduces maintenance burden
tags: strat, e2e, critical-paths, user-journey
---

## Limit E2E Tests to Critical User Paths

End-to-end tests are expensive to maintain and slow to run. Reserve them for critical user journeys that generate revenue or core functionality.

**Incorrect (E2E for everything):**

```typescript
// E2E tests for every feature
describe('User Settings', () => {
  it('changes theme to dark mode', async () => { /* 30s test */ })
  it('changes theme to light mode', async () => { /* 30s test */ })
  it('updates avatar', async () => { /* 30s test */ })
  it('changes language to Spanish', async () => { /* 30s test */ })
  it('changes language to French', async () => { /* 30s test */ })
  // ... 50 more settings tests
})

// E2E for edge cases
describe('Error handling', () => {
  it('shows error on network timeout', async () => { /* 30s test */ })
  it('shows error on invalid input', async () => { /* 30s test */ })
  // ... 30 more error tests
})

// Total: 100 E2E tests, 50 minutes runtime
```

**Correct (E2E for critical paths only):**

```typescript
// E2E for core revenue-generating flows
describe('Critical User Journeys', () => {
  it('completes signup to first purchase', async () => {
    await page.goto('/signup')
    await page.fill('[name=email]', 'new@customer.com')
    await page.fill('[name=password]', 'SecurePass123!')
    await page.click('button[type=submit]')

    await page.waitForURL('/dashboard')
    await page.click('[data-testid=browse-products]')
    await page.click('[data-testid=product-1]')
    await page.click('[data-testid=add-to-cart]')
    await page.click('[data-testid=checkout]')
    // ... complete purchase

    await expect(page.locator('.order-confirmation')).toBeVisible()
  })

  it('existing user can login and reorder', async () => { /* ... */ })

  it('user can contact support', async () => { /* ... */ })
})

// 3-5 critical E2E tests, 5 minutes runtime
// Settings, error handling tested at unit/integration level
```

**E2E test candidates:**
- Signup/onboarding flow
- Purchase/checkout
- Core feature happy path
- Authentication flows
- Critical admin operations

**Test at lower levels:**
- Input validation (unit)
- Error messages (unit)
- API edge cases (integration)
- Settings variations (integration)

Reference: [Testing Pyramid - Mike Cohn](https://www.mountaingoatsoftware.com/blog/the-forgotten-layer-of-the-test-automation-pyramid)
