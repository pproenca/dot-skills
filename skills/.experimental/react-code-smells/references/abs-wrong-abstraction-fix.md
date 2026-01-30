---
title: Fix Wrong Abstractions by Inlining First
impact: HIGH
impactDescription: recovers from 5× wrong abstraction cost, enables correct redesign
tags: abs, wrong-abstraction, inline, refactoring, technical-debt
---

## Fix Wrong Abstractions by Inlining First

When an abstraction is wrong, don't try to fix it in place. Inline it back into callers, then re-extract correctly with new understanding.

**Code Smell Indicators:**
- Abstraction has grown many parameters for "just one more use case"
- Every new feature requires modifying the abstraction
- Consumers work around the abstraction's assumptions
- You're afraid to change it because everything uses it

**Incorrect (trying to fix wrong abstraction in place):**

```tsx
// Original wrong abstraction
function useEntity(type, id, options = {}) {
  // Started simple, grew parameters for each use case
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(!options.skipInitialFetch)
  const [error, setError] = useState(null)

  useEffect(() => {
    if (options.skipInitialFetch) return
    if (options.pollInterval) {
      // Polling logic
    } else if (options.realtime) {
      // WebSocket logic
    } else {
      // Regular fetch logic
    }
    // ... 100 lines handling all variations
  }, [type, id, /* 10 more deps */])

  // Trying to add one more feature
  if (options.withRelations) {
    // Now it's even more complex
  }

  return { data, loading, error, /* 10 more values */ }
}

// Every consumer has unique options
useEntity('user', id, { withRelations: true, pollInterval: 5000 })
useEntity('product', id, { skipInitialFetch: true, realtime: true })
useEntity('order', id, { transform: x => x.items })
```

**Correct (inline first, then re-extract):**

```tsx
// Step 1: Inline back into each consumer
function UserProfile({ userId }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchUser(userId).then(setUser).finally(() => setLoading(false))
  }, [userId])

  // Inline related data fetch - this is what THIS component needs
  const [posts, setPosts] = useState([])
  useEffect(() => {
    if (user) fetchUserPosts(user.id).then(setPosts)
  }, [user])

  // Now we see what UserProfile actually needs
}

function LiveOrderStatus({ orderId }) {
  const [order, setOrder] = useState(null)

  // Inline WebSocket logic - this is what THIS component needs
  useEffect(() => {
    const ws = subscribeToOrder(orderId, setOrder)
    return () => ws.close()
  }, [orderId])

  // Now we see what LiveOrderStatus actually needs
}

// Step 2: After inlining, patterns emerge
// User fetching and Order subscriptions are DIFFERENT concerns
// They should NOT be in the same abstraction

// Step 3: Extract correct, focused abstractions
function useFetch<T>(fetcher: () => Promise<T>, deps: unknown[]) {
  // Simple fetch - nothing else
}

function useSubscription<T>(subscribe: (cb: (val: T) => void) => () => void, deps: unknown[]) {
  // Simple subscription - nothing else
}

// Step 4: Use focused abstractions
function UserProfile({ userId }) {
  const user = useFetch(() => fetchUser(userId), [userId])
  const posts = useFetch(() => fetchUserPosts(userId), [userId])
}

function LiveOrderStatus({ orderId }) {
  const order = useSubscription(cb => subscribeToOrder(orderId, cb), [orderId])
}
```

**The inlining process:**
1. Pick one consumer of the wrong abstraction
2. Copy the abstraction's code into the consumer
3. Delete parameters/branches this consumer doesn't use
4. Repeat for each consumer
5. Delete the original abstraction
6. Look at consumers - what patterns actually emerge?
7. Extract new, focused abstractions

**Why inlining works:**
- Removes wrong assumptions
- Shows what each consumer actually needs
- Prevents sunk cost fallacy
- Reveals the right abstractions through concrete code

**Principal engineer judgment:**
- Short-term: more code
- Long-term: correct, maintainable abstractions
- The wrong abstraction costs 5× more than temporary duplication

Reference: [The Wrong Abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction)
