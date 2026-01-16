---
title: Defer await Until Value Is Needed
impact: HIGH
impactDescription: enables implicit parallelization
tags: async, defer, promises, optimization, performance
---

## Defer await Until Value Is Needed

Start async operations immediately but defer `await` until the value is actually required. This allows work to proceed while promises resolve in the background.

**Incorrect (blocks immediately):**

```typescript
async function processOrder(orderId: string): Promise<OrderResult> {
  const order = await fetchOrder(orderId)  // Blocks here
  const inventory = await checkInventory(order.items)  // Must wait for order

  // Could have started inventory check earlier
  if (order.priority === 'express') {
    return processExpress(order, inventory)
  }
  return processStandard(order, inventory)
}
```

**Correct (deferred await):**

```typescript
async function processOrder(orderId: string): Promise<OrderResult> {
  const orderPromise = fetchOrder(orderId)  // Start immediately, don't await

  // Do other work while order fetches
  const config = loadProcessingConfig()

  const order = await orderPromise  // Now await when needed
  const inventory = await checkInventory(order.items)

  if (order.priority === 'express') {
    return processExpress(order, inventory)
  }
  return processStandard(order, inventory)
}
```

**Pattern for dependent-then-independent operations:**

```typescript
async function loadUserContent(userId: string): Promise<Content> {
  // Start user fetch (needed for dependent calls)
  const userPromise = fetchUser(userId)

  // Start independent operations immediately
  const settingsPromise = fetchGlobalSettings()
  const featuresPromise = fetchFeatureFlags()

  // Await user for dependent operations
  const user = await userPromise
  const ordersPromise = fetchOrders(user.id)
  const prefsPromise = fetchPreferences(user.id)

  // Await all remaining
  const [settings, features, orders, prefs] = await Promise.all([
    settingsPromise,
    featuresPromise,
    ordersPromise,
    prefsPromise,
  ])

  return { user, settings, features, orders, prefs }
}
```

Reference: [V8 Blog - Fast Async](https://v8.dev/blog/fast-async)
