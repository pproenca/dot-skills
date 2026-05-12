---
title: Split Context to Prevent Unnecessary Re-renders
impact: MEDIUM
impactDescription: reduces re-renders from context changes
tags: rstate, context, optimization, splitting
---

## Split Context to Prevent Unnecessary Re-renders

When context contains multiple values, split it so components only subscribe to what they need. This prevents re-renders when unrelated values change.

**Incorrect (single context with multiple values):**

```typescript
const AppContext = createContext({
  user: null,
  theme: 'light',
  notifications: []
})

function ThemeButton() {
  const { theme } = useContext(AppContext)
  // Re-renders when user or notifications change!
  return <button className={theme}>Toggle</button>
}
```

**Correct (split contexts):**

```typescript
const UserContext = createContext<User | null>(null)
const ThemeContext = createContext<'light' | 'dark'>('light')
const NotificationContext = createContext<Notification[]>([])

function ThemeButton() {
  const theme = useContext(ThemeContext)
  // Only re-renders when theme changes
  return <button className={theme}>Toggle</button>
}

function AppProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [theme, setTheme] = useState<'light' | 'dark'>('light')
  const [notifications, setNotifications] = useState<Notification[]>([])

  // React 19+: render <Context> directly as provider; <Context.Provider> is legacy
  return (
    <UserContext value={user}>
      <ThemeContext value={theme}>
        <NotificationContext value={notifications}>
          {children}
        </NotificationContext>
      </ThemeContext>
    </UserContext>
  )
}
```

**Alternative (use() for conditional context reading):**

```typescript
import { use } from 'react'

function Button({ showTheme }: { showTheme: boolean }) {
  if (showTheme) {
    const theme = use(ThemeContext)  // Conditional context reading
    return <button className={theme}>Themed</button>
  }
  return <button>Default</button>
}
// use() can read context conditionally, unlike useContext
```
