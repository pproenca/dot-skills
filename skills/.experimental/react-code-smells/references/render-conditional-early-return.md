---
title: Use Early Returns for Conditional Rendering
impact: MEDIUM
impactDescription: improves readability, reduces nesting by 50%
tags: render, conditional, early-return, readability, refactoring
---

## Use Early Returns for Conditional Rendering

Deeply nested ternaries and && chains obscure intent. Use early returns for guard clauses and clear rendering paths.

**Code Smell Indicators:**
- Nested ternary operators 2+ levels deep
- Multiple `&&` chains in JSX
- Can't tell at a glance what renders when
- "What actually renders here?" confusion

**Incorrect (nested ternaries and && chains):**

```tsx
function UserDashboard({ user, loading, error }) {
  return (
    <div className="dashboard">
      {loading ? (
        <Spinner />
      ) : error ? (
        <ErrorMessage error={error} />
      ) : user ? (
        user.isAdmin ? (
          <AdminDashboard user={user} />
        ) : user.isPremium ? (
          <PremiumDashboard user={user} />
        ) : (
          <BasicDashboard user={user} />
        )
      ) : (
        <LoginPrompt />
      )}
    </div>
  )
}
```

**Correct (early returns for clarity):**

```tsx
function UserDashboard({ user, loading, error }) {
  // Guard clauses with early returns
  if (loading) {
    return <Spinner />
  }

  if (error) {
    return <ErrorMessage error={error} />
  }

  if (!user) {
    return <LoginPrompt />
  }

  // Main render path - user definitely exists here
  if (user.isAdmin) {
    return <AdminDashboard user={user} />
  }

  if (user.isPremium) {
    return <PremiumDashboard user={user} />
  }

  return <BasicDashboard user={user} />
}
```

**Pattern: Extract conditional sections:**

```tsx
function UserDashboard({ user, loading, error }) {
  if (loading) return <Spinner />
  if (error) return <ErrorMessage error={error} />
  if (!user) return <LoginPrompt />

  return (
    <div className="dashboard">
      <Header user={user} />
      <DashboardContent user={user} />  {/* Handles admin/premium/basic internally */}
      <Footer />
    </div>
  )
}

function DashboardContent({ user }: { user: User }) {
  if (user.isAdmin) return <AdminDashboard user={user} />
  if (user.isPremium) return <PremiumDashboard user={user} />
  return <BasicDashboard user={user} />
}
```

**When && is OK:**

```tsx
// Single condition, simple content - && is fine
function Notification({ message, show }) {
  return (
    <div>
      {show && <Alert>{message}</Alert>}
    </div>
  )
}

// Multiple independent conditions - && is fine
function UserBadges({ user }) {
  return (
    <div className="badges">
      {user.isVerified && <VerifiedBadge />}
      {user.isPremium && <PremiumBadge />}
      {user.isAdmin && <AdminBadge />}
    </div>
  )
}
```

**When ternary is OK:**

```tsx
// Single level, both branches simple
function Button({ disabled, children }) {
  return (
    <button className={disabled ? 'btn-disabled' : 'btn-active'}>
      {children}
    </button>
  )
}
```

**Decision guide:**
```
Conditional rendering:
├── Guard clause (loading, error, not found)? → Early return
├── Multiple mutually exclusive paths? → Early returns or switch
├── Simple presence check? → &&
├── Simple either/or? → Ternary
└── Complex nested conditions? → Extract to component
```

Reference: [Conditional Rendering](https://react.dev/learn/conditional-rendering)
