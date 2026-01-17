---
title: Avoid Overusing Context for Frequently Changing State
impact: MEDIUM
impactDescription: prevents global re-renders from state updates
tags: rerender, context, state-management, performance
---

## Avoid Overusing Context for Frequently Changing State

Context triggers re-renders in ALL consuming components when any part of the value changes. Use context for low-frequency updates (theme, auth) and dedicated state libraries for high-frequency updates.

**Incorrect (all consumers re-render on any change):**

```typescript
const AppContext = createContext(null)

function AppProvider({ children }) {
  const [user, setUser] = useState(null)
  const [cart, setCart] = useState([])
  const [notifications, setNotifications] = useState([])
  const [theme, setTheme] = useState('light')

  // Single context with everything
  const value = { user, cart, notifications, theme, setCart, setTheme }

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>
}

// Every component using AppContext re-renders when cart updates
function Header() {
  const { user, theme } = useContext(AppContext)  // Re-renders on cart change
  return <HeaderContent user={user} theme={theme} />
}
```

**Correct (split contexts by update frequency):**

```typescript
// Low-frequency contexts
const AuthContext = createContext(null)
const ThemeContext = createContext(null)

// High-frequency state with Zustand
import { create } from 'zustand'

const useCartStore = create((set) => ({
  items: [],
  addItem: (item) => set((state) => ({ items: [...state.items, item] })),
  removeItem: (id) => set((state) => ({
    items: state.items.filter(item => item.id !== id)
  })),
}))

function Header() {
  const { user } = useContext(AuthContext)  // Only re-renders on auth change
  const theme = useContext(ThemeContext)
  return <HeaderContent user={user} theme={theme} />
}

function CartButton() {
  const itemCount = useCartStore((state) => state.items.length)
  // Only re-renders when item count changes, not on every cart update
  return <Badge count={itemCount} />
}
```

**Alternative: Memoize context value:**

```typescript
function AppProvider({ children }) {
  const [user, setUser] = useState(null)
  const [theme, setTheme] = useState('light')

  const value = useMemo(
    () => ({ user, theme, setUser, setTheme }),
    [user, theme]
  )

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>
}
```

**Context use cases:**
| Use Case | Solution |
|----------|----------|
| Theme (infrequent) | Context |
| Auth state (infrequent) | Context |
| Cart items (frequent) | Zustand/Jotai |
| Form state (frequent) | Local state or React Hook Form |
| Real-time data (frequent) | TanStack Query + subscriptions |

Reference: [Zustand Documentation](https://github.com/pmndrs/zustand)
