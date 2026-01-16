---
title: Catch Async/Await Error Handling Mistakes
impact: MEDIUM
impactDescription: prevents unhandled promise rejections
tags: pattern, async, promises, error-handling
---

## Catch Async/Await Error Handling Mistakes

Async/await makes asynchronous code look synchronous, but error handling behaves differently. Unhandled promise rejections, missing try/catch, and forgotten await keywords are common bugs.

**Incorrect (async error handling mistakes):**

```javascript
// Bug 1: Missing try/catch
async function fetchUser(id) {
  const response = await fetch(`/api/users/${id}`)
  return response.json()  // Network errors crash the app
}

// Bug 2: Forgotten await
async function processOrder(orderId) {
  const order = await getOrder(orderId)
  validateOrder(order)  // If async, validation runs after return!
  return order
}

// Bug 3: Errors lost in Promise.all
async function loadDashboard() {
  const [users, orders, stats] = await Promise.all([
    fetchUsers(),    // If this fails...
    fetchOrders(),   // These still run but error is unclear
    fetchStats()
  ])
}
```

**Correct (proper async error handling):**

```javascript
// Fixed 1: Try/catch for error handling
async function fetchUser(id) {
  try {
    const response = await fetch(`/api/users/${id}`)
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`)
    }
    return response.json()
  } catch (error) {
    logger.error('fetch_user_failed', { id, error: error.message })
    throw error  // Re-throw or return fallback
  }
}

// Fixed 2: Await all async operations
async function processOrder(orderId) {
  const order = await getOrder(orderId)
  await validateOrder(order)  // Properly awaited
  return order
}

// Fixed 3: Handle Promise.all failures gracefully
async function loadDashboard() {
  const results = await Promise.allSettled([
    fetchUsers(),
    fetchOrders(),
    fetchStats()
  ])
  // Check each result: { status: 'fulfilled', value } or { status: 'rejected', reason }
  const [usersResult, ordersResult, statsResult] = results
  if (usersResult.status === 'rejected') {
    logger.error('users_fetch_failed', { error: usersResult.reason })
  }
}
```

**Async debugging tips:**
- Add `.catch()` to all promises in development to surface errors
- Use `unhandledRejection` event handler to log missed errors
- ESLint rules: `require-await`, `no-floating-promises`

Reference: [Coders.dev - The Art of Debugging](https://www.coders.dev/blog/the-art-of-debugging-techniques-for-efficient-troubleshooting.html)
