---
title: Remove Effects That Aren't Synchronization
impact: MEDIUM-HIGH
impactDescription: simplifies code by 40%, eliminates sync bugs
tags: effect, unnecessary, derived-state, event-handlers, refactoring
---

## Remove Effects That Aren't Synchronization

Effects are for synchronizing with external systems. Derived state and event responses don't need effects.

**Code Smell Indicators:**
- Effect that only calls setState
- Effect triggered by user action
- Effect computing derived values
- Effect chaining (effect1 → state → effect2)

**Incorrect (effect for derived state):**

```tsx
function ProductList({ products, category }) {
  const [filteredProducts, setFilteredProducts] = useState([])

  // Effect to sync derived state - WRONG
  useEffect(() => {
    setFilteredProducts(products.filter(p => p.category === category))
  }, [products, category])

  return <List items={filteredProducts} />
}
```

**Correct (calculate during render):**

```tsx
function ProductList({ products, category }) {
  // Derived value - calculated during render
  const filteredProducts = products.filter(p => p.category === category)

  return <List items={filteredProducts} />
}
```

**Incorrect (effect for event response):**

```tsx
function ContactForm() {
  const [formData, setFormData] = useState({})
  const [submitted, setSubmitted] = useState(false)

  // Effect responds to submission - WRONG
  useEffect(() => {
    if (submitted) {
      sendToServer(formData)
      setSubmitted(false)
    }
  }, [submitted, formData])

  function handleSubmit() {
    setSubmitted(true)
  }

  return <form onSubmit={handleSubmit}>...</form>
}
```

**Correct (direct event handler):**

```tsx
function ContactForm() {
  const [formData, setFormData] = useState({})

  // Direct response to event
  async function handleSubmit(e) {
    e.preventDefault()
    await sendToServer(formData)
  }

  return <form onSubmit={handleSubmit}>...</form>
}
```

**Incorrect (effect chain):**

```tsx
function Profile({ userId }) {
  const [user, setUser] = useState(null)
  const [posts, setPosts] = useState([])

  // Effect 1: fetch user
  useEffect(() => {
    fetchUser(userId).then(setUser)
  }, [userId])

  // Effect 2: fetch posts when user changes - WRONG pattern
  useEffect(() => {
    if (user) {
      fetchPosts(user.id).then(setPosts)
    }
  }, [user])

  return <ProfileView user={user} posts={posts} />
}
```

**Correct (parallel fetching):**

```tsx
function Profile({ userId }) {
  const [user, setUser] = useState(null)
  const [posts, setPosts] = useState([])

  // Single effect, parallel fetching
  useEffect(() => {
    let cancelled = false

    async function loadData() {
      const [userData, postsData] = await Promise.all([
        fetchUser(userId),
        fetchPosts(userId),
      ])
      if (!cancelled) {
        setUser(userData)
        setPosts(postsData)
      }
    }

    loadData()
    return () => { cancelled = true }
  }, [userId])

  return <ProfileView user={user} posts={posts} />
}
```

**Decision tree:**

```
Do I need an effect?
├── Computing derived value? → No, calculate during render
├── Responding to user action? → No, use event handler
├── Transforming props to state? → No, use the prop directly
├── Synchronizing with external system? → YES, use effect
│   ├── WebSocket/subscription? → Effect with cleanup
│   ├── Browser API (title, focus)? → Effect
│   └── Third-party library? → Effect with cleanup
└── Fetching data on mount/change? → Effect (or data library)
```

Reference: [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
