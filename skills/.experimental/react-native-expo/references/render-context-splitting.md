---
title: Split Context to Prevent Unnecessary Re-renders
impact: MEDIUM
impactDescription: prevents N×M re-renders across consumers
tags: render, context, state-management, optimization, react
---

## Split Context to Prevent Unnecessary Re-renders

A single large context re-renders all consumers when any value changes. Split context by update frequency.

**Incorrect (monolithic context):**

```tsx
const AppContext = createContext()

function AppProvider({ children }) {
  const [user, setUser] = useState(null)
  const [theme, setTheme] = useState('light')
  const [notifications, setNotifications] = useState([])
  const [cart, setCart] = useState([])

  // Single context with everything
  const value = {
    user, setUser,
    theme, setTheme,
    notifications, setNotifications,
    cart, setCart,
  }

  return (
    <AppContext.Provider value={value}>
      {children}
    </AppContext.Provider>
  )
}

// Every consumer re-renders when ANY value changes
function Header() {
  const { user } = useContext(AppContext)  // Re-renders on cart change!
  return <Text>{user?.name}</Text>
}
```

**Correct (split by update frequency):**

```tsx
// Separate contexts for different update frequencies
const UserContext = createContext()
const ThemeContext = createContext()
const NotificationsContext = createContext()
const CartContext = createContext()

function AppProvider({ children }) {
  return (
    <UserProvider>
      <ThemeProvider>
        <NotificationsProvider>
          <CartProvider>
            {children}
          </CartProvider>
        </NotificationsProvider>
      </ThemeProvider>
    </UserProvider>
  )
}

// Each consumer only re-renders when its context changes
function Header() {
  const { user } = useContext(UserContext)  // Only user changes cause re-render
  return <Text>{user?.name}</Text>
}

function CartBadge() {
  const { cart } = useContext(CartContext)  // Only cart changes cause re-render
  return <Badge count={cart.length} />
}
```

**Split state from actions:**

```tsx
// State context (changes frequently)
const CartStateContext = createContext()
// Actions context (never changes)
const CartActionsContext = createContext()

function CartProvider({ children }) {
  const [items, setItems] = useState([])

  // Stable actions object
  const actions = useMemo(() => ({
    addItem: (item) => setItems(prev => [...prev, item]),
    removeItem: (id) => setItems(prev => prev.filter(i => i.id !== id)),
    clearCart: () => setItems([]),
  }), [])

  return (
    <CartStateContext.Provider value={items}>
      <CartActionsContext.Provider value={actions}>
        {children}
      </CartActionsContext.Provider>
    </CartStateContext.Provider>
  )
}

// Components that only dispatch don't re-render on state changes
function AddToCartButton({ product }) {
  const { addItem } = useContext(CartActionsContext)  // Never re-renders
  return <Button onPress={() => addItem(product)} title="Add" />
}

// Components that read state re-render when state changes
function CartTotal() {
  const items = useContext(CartStateContext)  // Re-renders on cart changes
  const total = items.reduce((sum, i) => sum + i.price, 0)
  return <Text>${total}</Text>
}
```

**Use custom hooks for cleaner API:**

```tsx
function useCartState() {
  return useContext(CartStateContext)
}

function useCartActions() {
  return useContext(CartActionsContext)
}

// Usage
function CartIcon() {
  const items = useCartState()
  return <Badge count={items.length} />
}

function ProductCard({ product }) {
  const { addItem } = useCartActions()
  return <Button onPress={() => addItem(product)} title="Add to Cart" />
}
```

Reference: [React Context Documentation](https://react.dev/reference/react/useContext)
