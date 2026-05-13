---
title: Each context holds one independently-changing piece of state — split fat contexts apart
impact: MEDIUM
impactDescription: prevents whole-subtree re-renders when one unrelated context value changes; lets consumers subscribe to only what they need
tags: rstate, context-split, single-purpose-context, re-render-isolation
---

## Each context holds one independently-changing piece of state — split fat contexts apart

**Pattern intent:** a context value rebuilds (and re-renders all consumers) whenever any field of its value changes. So a context whose value is `{ user, theme, notifications }` re-renders the theme button every time notifications mutate. The pattern is to keep contexts narrow — one independently-evolving concern each.

### Shapes to recognize

- A single `AppContext` whose `value={{ user, theme, notifications, settings, ... }}` is recreated each render — every consumer re-renders on every change.
- A context whose value object is created inline at the provider (`<C value={{ a, b }}>`) without `useMemo` — fresh object identity each render, every consumer re-renders unconditionally.
- A "context split" that's only at the type level (split interfaces) but the runtime still has one provider — no re-render benefit.
- A Zustand/Jotai/Redux store wired through one context provider, where selector consumers re-render despite "subscribing" — usually a missing selector, not a context problem; verify before splitting.
- Two consumers reading the same fat context where one only needs the theme: that consumer's re-render trace shows it firing on unrelated state updates.

The canonical resolution: one context per concern. Provider compositions sit nested in the tree. Consumers `useContext`/`use(Context)` only the slice they need. If splitting isn't possible (legacy), wrap the value in `useMemo` keyed on the actual changing parts and use selector hooks.

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

### In disguise — context with a freshly-constructed value object

The grep-friendly anti-pattern is one fat `AppContext` with `{ user, theme, notifications }`. The same anti-pattern *also* surfaces when a single context's `value` is a fresh object created in the provider's render — every render rebuilds the object, every consumer re-renders, regardless of whether the *fields* changed.

**Incorrect — in disguise (single-purpose context, but value object recreated each render):**

```typescript
const SettingsContext = createContext<{ theme: 'light' | 'dark'; setTheme: (t: 'light' | 'dark') => void }>(
  { theme: 'light', setTheme: () => {} }
)

function SettingsProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light')

  // ❌ New object every render — even though `theme` and `setTheme` are stable
  return (
    <SettingsContext value={{ theme, setTheme }}>
      {children}
    </SettingsContext>
  )
}

// SomePage.tsx renders. Provider re-renders for an unrelated reason
// (parent state change). The `{ theme, setTheme }` object is now a new reference.
// Every consumer of SettingsContext re-renders. The context "split" achieved nothing.
```

**Correct — stabilize the value object:**

```typescript
function SettingsProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light')

  // ✅ Memoize so the value object is reference-stable when theme is unchanged.
  const value = useMemo(() => ({ theme, setTheme }), [theme])

  return <SettingsContext value={value}>{children}</SettingsContext>
}
```

**Even better — split state and setter into two contexts** (consumers that only need the setter don't re-render when theme changes):

```typescript
const ThemeContext = createContext<'light' | 'dark'>('light')
const ThemeSetterContext = createContext<(t: 'light' | 'dark') => void>(() => {})

function SettingsProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light')
  // setTheme is stable across renders; ThemeContext only changes when theme changes.
  return (
    <ThemeSetterContext value={setTheme}>
      <ThemeContext value={theme}>{children}</ThemeContext>
    </ThemeSetterContext>
  )
}
```

This is the React-canonical state/dispatch split that pays off when many components need to *call* the setter but few need to *read* the value (or vice-versa).

---

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
