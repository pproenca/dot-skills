---
title: Compose Small Hooks Rather Than One Large Hook
impact: MEDIUM-HIGH
impactDescription: improves testability 3×, enables selective reuse
tags: hook, composition, small-hooks, single-responsibility, refactoring
---

## Compose Small Hooks Rather Than One Large Hook

Large hooks that do many things are hard to test and reuse. Compose focused hooks for flexibility and maintainability.

**Code Smell Indicators:**
- Hook over 50 lines
- Hook has 5+ useState calls
- Tests need to mock many things
- Can't reuse part of hook's logic

**Incorrect (monolithic hook):**

```tsx
function useUserDashboard(userId: string) {
  // User data
  const [user, setUser] = useState(null)
  const [userLoading, setUserLoading] = useState(true)

  // Notifications
  const [notifications, setNotifications] = useState([])
  const [unreadCount, setUnreadCount] = useState(0)

  // Preferences
  const [theme, setTheme] = useState('light')
  const [language, setLanguage] = useState('en')

  // Activity
  const [activities, setActivities] = useState([])
  const [activityPage, setActivityPage] = useState(1)

  useEffect(() => {
    fetchUser(userId).then(setUser).finally(() => setUserLoading(false))
  }, [userId])

  useEffect(() => {
    const unsubscribe = subscribeToNotifications(userId, n => {
      setNotifications(prev => [n, ...prev])
      setUnreadCount(c => c + 1)
    })
    return unsubscribe
  }, [userId])

  useEffect(() => {
    const prefs = localStorage.getItem('preferences')
    if (prefs) {
      const { theme, language } = JSON.parse(prefs)
      setTheme(theme)
      setLanguage(language)
    }
  }, [])

  useEffect(() => {
    fetchActivities(userId, activityPage).then(setActivities)
  }, [userId, activityPage])

  // 20 more lines of handlers...

  return {
    user, userLoading,
    notifications, unreadCount, markNotificationRead,
    theme, setTheme, language, setLanguage,
    activities, activityPage, loadMoreActivities,
  }
}
```

**Correct (composed from focused hooks):**

```tsx
// Small, focused hook for user data
function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchUser(userId).then(setUser).finally(() => setLoading(false))
  }, [userId])

  return { user, loading }
}

// Small, focused hook for notifications
function useNotifications(userId: string) {
  const [notifications, setNotifications] = useState<Notification[]>([])
  const unreadCount = notifications.filter(n => !n.read).length

  useEffect(() => {
    return subscribeToNotifications(userId, n => {
      setNotifications(prev => [n, ...prev])
    })
  }, [userId])

  const markRead = useCallback((id: string) => {
    setNotifications(prev =>
      prev.map(n => n.id === id ? { ...n, read: true } : n)
    )
  }, [])

  return { notifications, unreadCount, markRead }
}

// Small, focused hook for preferences
function usePreferences() {
  const [theme, setTheme] = useState('light')
  const [language, setLanguage] = useState('en')

  useEffect(() => {
    const prefs = localStorage.getItem('preferences')
    if (prefs) {
      const parsed = JSON.parse(prefs)
      setTheme(parsed.theme)
      setLanguage(parsed.language)
    }
  }, [])

  const updateTheme = useCallback((newTheme: string) => {
    setTheme(newTheme)
    localStorage.setItem('preferences', JSON.stringify({ theme: newTheme, language }))
  }, [language])

  return { theme, setTheme: updateTheme, language, setLanguage }
}

// Composed hook when you need everything
function useUserDashboard(userId: string) {
  const user = useUser(userId)
  const notifications = useNotifications(userId)
  const preferences = usePreferences()
  const activities = usePaginatedFetch((page) => fetchActivities(userId, page))

  return { user, notifications, preferences, activities }
}

// Or use hooks directly in component when you don't need everything
function NotificationBell({ userId }) {
  const { notifications, unreadCount, markRead } = useNotifications(userId)
  // Only notification logic, not user/preferences/activities
}
```

**Benefits of composition:**
- Test each hook in isolation
- Reuse individual hooks
- Smaller bundles (only import what you use)
- Clearer single responsibility

**Composition patterns:**
```
Large Feature
├── useUser (data fetching)
├── useNotifications (real-time)
├── usePreferences (local storage)
└── usePaginatedFetch (pagination)

Each hook: 20-40 lines, one responsibility
```

Reference: [Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
