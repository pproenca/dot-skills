---
title: Split Contexts to Isolate High-Frequency Updates
impact: MEDIUM-HIGH
impactDescription: 5-50× fewer re-renders for low-frequency consumers
tags: sub, context, splitting, re-renders
---

## Split Contexts to Isolate High-Frequency Updates

A single context holding mixed fast-changing and slow-changing values forces every consumer to re-render on any change. Splitting by update frequency ensures components only re-render when their specific data changes.

**Incorrect (all consumers re-render on any context value change):**

```tsx
interface AppContextValue {
  theme: "light" | "dark"
  currentUser: User
  notifications: Notification[]
  unreadCount: number
}

const AppContext = createContext<AppContextValue>(null!)

function AppProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState<"light" | "dark">("light")
  const [currentUser, setCurrentUser] = useState<User>(initialUser)
  const [notifications, setNotifications] = useState<Notification[]>([])

  const value = {
    theme,
    currentUser,
    notifications,
    unreadCount: notifications.filter((n) => !n.read).length,
  }

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>
}

// Re-renders every time notifications change, even though it only reads theme
function PageHeader() {
  const { theme } = useContext(AppContext)
  return <header className={theme}>My App</header>
}
```

**Correct (consumers only re-render when their specific context changes):**

```tsx
const ThemeContext = createContext<{ theme: "light" | "dark" }>(null!)
const UserContext = createContext<{ currentUser: User }>(null!)
const NotificationContext = createContext<{
  notifications: Notification[]
  unreadCount: number
}>(null!)

function AppProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState<"light" | "dark">("light")
  const [currentUser, setCurrentUser] = useState<User>(initialUser)
  const [notifications, setNotifications] = useState<Notification[]>([])

  return (
    <ThemeContext.Provider value={{ theme }}>
      <UserContext.Provider value={{ currentUser }}>
        <NotificationContext.Provider
          value={{
            notifications,
            unreadCount: notifications.filter((n) => !n.read).length,
          }}
        >
          {children}
        </NotificationContext.Provider>
      </UserContext.Provider>
    </ThemeContext.Provider>
  )
}

// Only re-renders when theme changes
function PageHeader() {
  const { theme } = useContext(ThemeContext)
  return <header className={theme}>My App</header>
}
```

Reference: [React Docs — Scaling Up with Reducer and Context](https://react.dev/learn/scaling-up-with-reducer-and-context)
