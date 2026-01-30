---
title: Split God Components by Responsibility
impact: CRITICAL
impactDescription: reduces component complexity by 70%, enables parallel development
tags: comp, god-component, split, single-responsibility, refactoring
---

## Split God Components by Responsibility

Components over 200 lines with multiple responsibilities are god components. Split by finding natural seams between concerns.

**Code Smell Indicators:**
- 200+ lines in a single component
- Multiple unrelated useState calls
- Multiple useEffect calls for different purposes
- Regions marked with comments like "// User section", "// Cart section"
- File requires scrolling to understand

**Incorrect (god component doing everything):**

```tsx
function Dashboard() {
  // User state
  const [user, setUser] = useState(null)
  const [userLoading, setUserLoading] = useState(true)

  // Notifications state
  const [notifications, setNotifications] = useState([])
  const [unreadCount, setUnreadCount] = useState(0)

  // Analytics state
  const [metrics, setMetrics] = useState(null)
  const [dateRange, setDateRange] = useState('week')

  // Settings state
  const [settings, setSettings] = useState({})
  const [settingsOpen, setSettingsOpen] = useState(false)

  // User effect
  useEffect(() => {
    fetchUser().then(setUser).finally(() => setUserLoading(false))
  }, [])

  // Notifications effect
  useEffect(() => {
    const unsubscribe = subscribeToNotifications(n => {
      setNotifications(prev => [...prev, n])
      setUnreadCount(prev => prev + 1)
    })
    return unsubscribe
  }, [])

  // Analytics effect
  useEffect(() => {
    fetchMetrics(dateRange).then(setMetrics)
  }, [dateRange])

  // ... 150 more lines of handlers and JSX
}
```

**Correct (split by responsibility):**

```tsx
// Each component owns its state and effects
function Dashboard() {
  return (
    <DashboardLayout>
      <UserHeader />
      <NotificationCenter />
      <AnalyticsPanel />
      <SettingsDrawer />
    </DashboardLayout>
  )
}

function UserHeader() {
  const { user, loading } = useUser()
  if (loading) return <HeaderSkeleton />
  return <Header user={user} />
}

function NotificationCenter() {
  const { notifications, unreadCount, markRead } = useNotifications()
  return (
    <NotificationPanel
      notifications={notifications}
      unreadCount={unreadCount}
      onMarkRead={markRead}
    />
  )
}

function AnalyticsPanel() {
  const [dateRange, setDateRange] = useState('week')
  const { metrics, loading } = useMetrics(dateRange)
  return (
    <Analytics
      metrics={metrics}
      loading={loading}
      dateRange={dateRange}
      onDateRangeChange={setDateRange}
    />
  )
}

function SettingsDrawer() {
  const [open, setOpen] = useState(false)
  const { settings, updateSettings } = useSettings()
  return (
    <>
      <SettingsButton onClick={() => setOpen(true)} />
      <Drawer open={open} onClose={() => setOpen(false)}>
        <SettingsForm settings={settings} onSave={updateSettings} />
      </Drawer>
    </>
  )
}
```

**Finding the seams:**
1. Group related useState + useEffect calls
2. Identify regions separated by comments
3. Look for state that never interacts with other state
4. Find UI sections that could be independently tested

**Safe transformation steps:**
1. Identify a cohesive "region" of state + effects + UI
2. Extract state and effects to a custom hook
3. Extract UI to a new component using the hook
4. Verify behavior is unchanged
5. Repeat for next region

**Size heuristics:**
- Components: 50-150 lines ideal, 200 max
- Hooks: 30-80 lines ideal
- If you need a table of contents, split it

Reference: [Keeping Components Pure](https://react.dev/learn/keeping-components-pure)
