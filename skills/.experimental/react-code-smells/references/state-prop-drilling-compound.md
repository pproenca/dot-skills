---
title: Replace Prop Drilling with Compound Components
impact: CRITICAL
impactDescription: eliminates 5-10 intermediate prop passes, reduces coupling by 80%
tags: state, prop-drilling, compound-components, composition, refactoring
---

## Replace Prop Drilling with Compound Components

Props passed through 3+ component layers signal a composition problem. Compound components co-locate related state and behavior while exposing a flexible API.

**Code Smell Indicators:**
- Props passed through components that don't use them
- Adding a new feature requires touching 5+ files
- Intermediate components have props like `onItemClick` they just forward

**Incorrect (drilling through 4 layers):**

```tsx
function Dashboard({ user, onLogout, theme, notifications }) {
  return (
    <Layout theme={theme}>
      <Header user={user} onLogout={onLogout} notifications={notifications} />
      <Content user={user} theme={theme} />
    </Layout>
  )
}

function Header({ user, onLogout, notifications }) {
  return (
    <nav>
      <Logo />
      <UserMenu user={user} onLogout={onLogout} />
      <NotificationBell notifications={notifications} />
    </nav>
  )
}

function UserMenu({ user, onLogout }) {
  return (
    <Menu>
      <span>{user.name}</span>
      <button onClick={onLogout}>Logout</button>
    </Menu>
  )
}
```

**Correct (compound component pattern):**

```tsx
function Dashboard() {
  return (
    <DashboardProvider>
      <Dashboard.Layout>
        <Dashboard.Header>
          <Dashboard.Logo />
          <Dashboard.UserMenu />
          <Dashboard.Notifications />
        </Dashboard.Header>
        <Dashboard.Content />
      </Dashboard.Layout>
    </DashboardProvider>
  )
}

// Each sub-component accesses only what it needs
function UserMenu() {
  const { user, logout } = useDashboard()
  return (
    <Menu>
      <span>{user.name}</span>
      <button onClick={logout}>Logout</button>
    </Menu>
  )
}

Dashboard.UserMenu = UserMenu
```

**When NOT to refactor:**
- Props only pass through 1-2 layers
- The intermediate components might need the props later
- You're building a library with explicit prop contracts

**Safe transformation steps:**
1. Identify the prop drilling chain
2. Create a context for the shared state
3. Create a provider component
4. Convert leaf components to use the context
5. Remove intermediate props one layer at a time

Reference: [Compound Components Pattern](https://kentcdodds.com/blog/compound-components-with-react-hooks)
