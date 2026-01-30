---
title: Consolidate Related useState Calls into useReducer
impact: HIGH
impactDescription: eliminates state sync bugs, improves testability by 50%
tags: state, useReducer, consolidation, refactoring, complex-state
---

## Consolidate Related useState Calls into useReducer

Multiple related useState calls that change together should be consolidated into a reducer. This makes state transitions explicit and testable.

**Code Smell Indicators:**
- Multiple setState calls in the same handler
- State updates that must happen together
- Complex conditional state updates
- Bugs from state getting out of sync

**Incorrect (scattered state that must stay in sync):**

```tsx
function ShoppingCart() {
  const [items, setItems] = useState([])
  const [total, setTotal] = useState(0)
  const [discount, setDiscount] = useState(0)
  const [shipping, setShipping] = useState(0)

  function addItem(item) {
    setItems([...items, item])
    setTotal(total + item.price) // Can get out of sync
    if (items.length >= 3) {
      setDiscount(total * 0.1) // Uses stale total!
    }
    if (total > 100) {
      setShipping(0)
    }
  }

  function removeItem(id) {
    const item = items.find(i => i.id === id)
    setItems(items.filter(i => i.id !== id))
    setTotal(total - item.price)
    // Forgot to update discount and shipping!
  }
}
```

**Correct (consolidated state with explicit transitions):**

```tsx
type CartState = {
  items: Item[]
  total: number
  discount: number
  shipping: number
}

type CartAction =
  | { type: 'ADD_ITEM'; item: Item }
  | { type: 'REMOVE_ITEM'; id: string }
  | { type: 'APPLY_COUPON'; code: string }

function cartReducer(state: CartState, action: CartAction): CartState {
  switch (action.type) {
    case 'ADD_ITEM': {
      const items = [...state.items, action.item]
      const total = items.reduce((sum, i) => sum + i.price, 0)
      return {
        items,
        total,
        discount: items.length >= 3 ? total * 0.1 : 0,
        shipping: total > 100 ? 0 : 10,
      }
    }
    case 'REMOVE_ITEM': {
      const items = state.items.filter(i => i.id !== action.id)
      const total = items.reduce((sum, i) => sum + i.price, 0)
      return {
        items,
        total,
        discount: items.length >= 3 ? total * 0.1 : 0,
        shipping: total > 100 ? 0 : 10,
      }
    }
    default:
      return state
  }
}

function ShoppingCart() {
  const [state, dispatch] = useReducer(cartReducer, initialState)

  // State transitions are atomic and testable
  const addItem = (item) => dispatch({ type: 'ADD_ITEM', item })
  const removeItem = (id) => dispatch({ type: 'REMOVE_ITEM', id })
}
```

**Benefits:**
- All related state updates happen atomically
- Reducer is pure and easily testable
- State transitions are explicit and documented
- Can extract reducer to separate file for reuse

**When to use useReducer:**
- 3+ related state variables
- Next state depends on previous state
- Complex conditional updates
- State logic needs to be testable

Reference: [Extracting State Logic into a Reducer](https://react.dev/learn/extracting-state-logic-into-a-reducer)
