---
title: Avoid Unnecessary async/await
impact: HIGH
impactDescription: eliminates microtask queue overhead
tags: async, promises, overhead, optimization, performance
---

## Avoid Unnecessary async/await

Every `async` function wraps its return in a Promise, and every `await` schedules a microtask. For functions that just return a Promise, skip the wrapper.

**Incorrect (unnecessary Promise wrapping):**

```typescript
async function getUser(userId: string): Promise<User> {
  return await userRepository.findById(userId)
  // Creates extra Promise + microtask for no benefit
}

async function getUserName(userId: string): Promise<string> {
  const user = await getUser(userId)
  return user.name
  // Another unnecessary async wrapper
}

// Chain of 3 async functions = 3 extra microtasks
async function displayUserName(userId: string): Promise<void> {
  const name = await getUserName(userId)
  console.log(name)
}
```

**Correct (direct Promise return):**

```typescript
function getUser(userId: string): Promise<User> {
  return userRepository.findById(userId)
  // Returns Promise directly, no wrapping
}

function getUserName(userId: string): Promise<string> {
  return getUser(userId).then(user => user.name)
  // Single Promise chain
}

// Only use async where you need sequential await
async function displayUserName(userId: string): Promise<void> {
  const name = await getUserName(userId)
  console.log(name)
}
```

**When async/await IS needed:**
- Multiple sequential await statements
- Try/catch around await
- Conditional await logic
- Better readability for complex flows

**Note:** Modern V8 optimizes simple `return await` patterns, but the overhead still exists for function setup. The bigger win is avoiding async wrappers that don't need them.

Reference: [V8 Blog - Fast Async](https://v8.dev/blog/fast-async)
