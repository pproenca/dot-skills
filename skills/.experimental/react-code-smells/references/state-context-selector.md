---
title: Use Context Selectors to Prevent Cascade Re-renders
impact: HIGH
impactDescription: reduces context-triggered re-renders by 70-90%
tags: state, context, selectors, performance, refactoring
---

## Use Context Selectors to Prevent Cascade Re-renders

Monolithic context causes all consumers to re-render on any change. Split context or use selectors to subscribe to specific slices.

**Code Smell Indicators:**
- Performance issues traced to context updates
- Components re-render but their used data didn't change
- Large context with many unrelated values
- All consumers re-render when any value changes

**Incorrect (monolithic context re-renders everything):**

```tsx
const AppContext = createContext()

function AppProvider({ children }) {
  const [user, setUser] = useState(null)
  const [theme, setTheme] = useState('light')
  const [notifications, setNotifications] = useState([])
  const [cart, setCart] = useState([])

  return (
    <AppContext.Provider value={{
      user, setUser,
      theme, setTheme,
      notifications, setNotifications,
      cart, setCart,
    }}>
      {children}
    </AppContext.Provider>
  )
}

// Every component using any context value re-renders
// when ANY value changes
function UserAvatar() {
  const { user } = useContext(AppContext)
  // Re-renders when cart changes!
  return <img src={user.avatar} />
}
```

**Correct (split into focused contexts):**

```tsx
const UserContext = createContext()
const ThemeContext = createContext()
const NotificationContext = createContext()
const CartContext = createContext()

function AppProvider({ children }) {
  return (
    <UserProvider>
      <ThemeProvider>
        <NotificationProvider>
          <CartProvider>
            {children}
          </CartProvider>
        </NotificationProvider>
      </ThemeProvider>
    </UserProvider>
  )
}

// Only re-renders when user changes
function UserAvatar() {
  const { user } = useContext(UserContext)
  return <img src={user.avatar} />
}
```

**Alternative: use-context-selector library:**

```tsx
import { createContext, useContextSelector } from 'use-context-selector'

const AppContext = createContext()

function UserAvatar() {
  // Only re-renders when user.avatar changes
  const avatar = useContextSelector(AppContext, ctx => ctx.user.avatar)
  return <img src={avatar} />
}

function CartCount() {
  // Only re-renders when cart.length changes
  const count = useContextSelector(AppContext, ctx => ctx.cart.length)
  return <span>{count}</span>
}
```

**Pattern: Separate state from dispatch:**

```tsx
const CartStateContext = createContext()
const CartDispatchContext = createContext()

// Components that only dispatch never re-render on state changes
function AddToCartButton({ item }) {
  const dispatch = useContext(CartDispatchContext)
  // Never re-renders when cart items change
  return <button onClick={() => dispatch({ type: 'ADD', item })}>Add</button>
}
```

**Decision framework:**
```
Context re-rendering causing issues?
├── Few consumers, many updates → Split context
├── Many consumers, selective reads → use-context-selector
└── Dispatch-heavy consumers → Separate state/dispatch contexts
```

Reference: [Optimizing Context](https://react.dev/learn/passing-data-deeply-with-context#optimizing-re-renders-when-passing-objects-and-functions)
