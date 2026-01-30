---
title: Replace Prop Drilling with Component Composition
impact: CRITICAL
impactDescription: removes intermediate components from data flow, simplifies by 40%
tags: state, prop-drilling, composition, children, slots
---

## Replace Prop Drilling with Component Composition

Before reaching for context, consider if composition (passing components as children) solves the problem. This keeps components flexible without implicit dependencies.

**Code Smell Indicators:**
- Wrapper components exist only to pass props down
- You're tempted to add context for 2-3 props
- The "shape" of the component tree is rigid

**Incorrect (wrapper just passes props through):**

```tsx
function App() {
  const [user, setUser] = useState(null)
  return <Page user={user} onUserChange={setUser} />
}

function Page({ user, onUserChange }) {
  return (
    <div>
      <Sidebar user={user} onUserChange={onUserChange} />
      <Main />
    </div>
  )
}

function Sidebar({ user, onUserChange }) {
  return (
    <aside>
      <Navigation />
      <UserPanel user={user} onUserChange={onUserChange} />
    </aside>
  )
}
```

**Correct (compose at the top, pass components down):**

```tsx
function App() {
  const [user, setUser] = useState(null)

  return (
    <Page
      sidebar={
        <Sidebar
          userPanel={<UserPanel user={user} onUserChange={setUser} />}
        />
      }
    />
  )
}

function Page({ sidebar }) {
  return (
    <div>
      {sidebar}
      <Main />
    </div>
  )
}

function Sidebar({ userPanel }) {
  return (
    <aside>
      <Navigation />
      {userPanel}
    </aside>
  )
}
```

**Benefits:**
- Page and Sidebar don't know about user state
- Adding new user features doesn't touch intermediate components
- Components are more reusable (Sidebar works with any panel)

**When NOT to use:**
- When many components need the same data (context is better)
- When composition creates too many props (slot explosion)
- When the composed structure rarely changes

Reference: [Composition vs Inheritance](https://react.dev/learn/passing-data-deeply-with-context#before-you-use-context)
