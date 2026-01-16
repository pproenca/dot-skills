---
title: Implement Dynamic Mock Scenarios
impact: MEDIUM
impactDescription: Enables runtime mock state changes; supports complex test flows
tags: advanced, dynamic, scenarios, state, runtime
---

## Implement Dynamic Mock Scenarios

Use module-level state or scenario flags to switch between different mock behaviors at runtime. This enables testing different application states without restarting tests.

**Incorrect (static handlers for all scenarios):**

```typescript
// Can't test different user states without test setup changes
http.get('/api/user', () => {
  return HttpResponse.json({ name: 'John', plan: 'free' })
})
```

**Correct (dynamic scenario switching):**

```typescript
import { http, HttpResponse } from 'msw'

// Scenario state
type Scenario = 'default' | 'premium' | 'expired' | 'error'
let currentScenario: Scenario = 'default'

// Export function to change scenario
export function setScenario(scenario: Scenario) {
  currentScenario = scenario
}

export const handlers = [
  http.get('/api/user', () => {
    switch (currentScenario) {
      case 'premium':
        return HttpResponse.json({
          name: 'John',
          plan: 'premium',
          features: ['feature1', 'feature2', 'feature3'],
        })

      case 'expired':
        return HttpResponse.json({
          name: 'John',
          plan: 'expired',
          features: [],
          message: 'Please renew your subscription',
        })

      case 'error':
        return HttpResponse.json(
          { error: 'Service unavailable' },
          { status: 503 }
        )

      default:
        return HttpResponse.json({
          name: 'John',
          plan: 'free',
          features: ['feature1'],
        })
    }
  }),
]
```

**Usage in tests:**

```typescript
import { setScenario } from '../mocks/handlers'

describe('Subscription', () => {
  afterEach(() => {
    setScenario('default')  // Reset after each test
  })

  it('shows premium features for premium users', async () => {
    setScenario('premium')
    render(<Dashboard />)
    expect(await screen.findByText('Premium Features')).toBeInTheDocument()
  })

  it('shows renewal prompt for expired users', async () => {
    setScenario('expired')
    render(<Dashboard />)
    expect(await screen.findByText('Please renew')).toBeInTheDocument()
  })
})
```

**URL-based scenarios (for development):**

```typescript
http.get('/api/user', ({ request }) => {
  const url = new URL(request.url)
  const scenario = url.searchParams.get('_scenario')

  if (scenario === 'error') {
    return new HttpResponse(null, { status: 500 })
  }

  return HttpResponse.json({ name: 'John' })
})

// In browser: /dashboard?_scenario=error
```

**When NOT to use this pattern:**
- Simple tests with single states don't need scenario complexity

Reference: [Dynamic Mock Scenarios](https://mswjs.io/docs/best-practices/dynamic-mock-scenarios)
