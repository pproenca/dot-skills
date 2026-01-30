---
title: Never Call Hooks Conditionally
impact: HIGH
impactDescription: prevents "Rendered fewer hooks" crashes and state corruption
tags: hook, rules-of-hooks, conditional, early-return, refactoring
---

## Never Call Hooks Conditionally

React relies on hook call order being consistent. Conditional hooks break React's internal state tracking.

**Code Smell Indicators:**
- Hooks inside if statements
- Hooks after early returns
- Hooks inside loops
- "Rendered more/fewer hooks than expected" errors

**Incorrect (conditional hooks):**

```tsx
function UserProfile({ userId, showDetails }) {
  // Early return before hooks - BREAKS RULES
  if (!userId) {
    return <div>No user selected</div>
  }

  // This hook wasn't called when userId was null
  const [user, setUser] = useState(null)

  // Conditional hook - BREAKS RULES
  if (showDetails) {
    const [details, setDetails] = useState(null)
    useEffect(() => {
      fetchDetails(userId).then(setDetails)
    }, [userId])
  }

  // Hook in loop - BREAKS RULES
  const [items, setItems] = useState([])
  items.forEach((item, i) => {
    const [expanded, setExpanded] = useState(false)  // Hook in loop!
  })

  useEffect(() => {
    fetchUser(userId).then(setUser)
  }, [userId])

  return <Profile user={user} />
}
```

**Correct (hooks before conditions):**

```tsx
function UserProfile({ userId, showDetails }) {
  // ALL hooks called unconditionally, in same order every render
  const [user, setUser] = useState(null)
  const [details, setDetails] = useState(null)

  useEffect(() => {
    if (userId) {
      fetchUser(userId).then(setUser)
    }
  }, [userId])

  useEffect(() => {
    if (showDetails && userId) {
      fetchDetails(userId).then(setDetails)
    }
  }, [showDetails, userId])

  // Conditions AFTER hooks
  if (!userId) {
    return <div>No user selected</div>
  }

  return <Profile user={user} details={showDetails ? details : null} />
}
```

**Pattern: Extract to component for conditional rendering:**

```tsx
// When hook is truly conditional, extract to separate component
function UserProfile({ userId }) {
  if (!userId) {
    return <div>No user selected</div>
  }

  // Render component that uses hooks
  return <UserProfileContent userId={userId} />
}

function UserProfileContent({ userId }) {
  // Hooks always called - this component only renders when userId exists
  const [user, setUser] = useState(null)

  useEffect(() => {
    fetchUser(userId).then(setUser)
  }, [userId])

  return <Profile user={user} />
}
```

**Pattern: Custom hook with conditional logic inside:**

```tsx
// Move condition inside the hook, not around it
function useUser(userId: string | null) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    // Condition inside effect, not around hook
    if (!userId) {
      setUser(null)
      return
    }

    setLoading(true)
    fetchUser(userId)
      .then(setUser)
      .finally(() => setLoading(false))
  }, [userId])

  return { user, loading }
}

// Hook is called every render, condition is handled internally
function UserProfile({ userId }) {
  const { user, loading } = useUser(userId)  // Always called

  if (!userId) return <div>No user selected</div>
  if (loading) return <Spinner />
  return <Profile user={user} />
}
```

**Pattern: Handle loops with map key + component:**

```tsx
// Instead of hooks in loops, map to components
function ItemList({ items }) {
  return (
    <ul>
      {items.map(item => (
        <ExpandableItem key={item.id} item={item} />
      ))}
    </ul>
  )
}

// Each component instance has its own hook calls
function ExpandableItem({ item }) {
  const [expanded, setExpanded] = useState(false)  // OK in component
  return (
    <li>
      <button onClick={() => setExpanded(!expanded)}>Toggle</button>
      {expanded && <Details item={item} />}
    </li>
  )
}
```

Reference: [Rules of Hooks](https://react.dev/reference/rules/rules-of-hooks)
