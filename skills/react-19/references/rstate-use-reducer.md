---
title: Use useReducer for Complex State Logic
impact: MEDIUM
impactDescription: clearer state transitions, easier testing
tags: state, useReducer, complex, actions
---

## Use useReducer for Complex State Logic

When state has multiple sub-values or complex update logic, useReducer provides clearer state transitions and easier testing.

**Incorrect (multiple related useState calls):**

```typescript
function ShoppingCart() {
  const [items, setItems] = useState([])
  const [total, setTotal] = useState(0)
  const [discount, setDiscount] = useState(0)
  const [loading, setLoading] = useState(false)

  function addItem(item) {
    setItems([...items, item])
    setTotal(total + item.price)
    // Easy to forget to update all related state
  }

  function applyDiscount(code) {
    setLoading(true)
    // Complex logic spread across multiple setters
  }
}
```

**Correct (useReducer for related state):**

```typescript
type CartState = {
  items: Item[]
  total: number
  discount: number
  loading: boolean
}

type CartAction =
  | { type: 'ADD_ITEM'; item: Item }
  | { type: 'REMOVE_ITEM'; id: string }
  | { type: 'APPLY_DISCOUNT'; code: string; amount: number }
  | { type: 'SET_LOADING'; loading: boolean }

function cartReducer(state: CartState, action: CartAction): CartState {
  switch (action.type) {
    case 'ADD_ITEM':
      return {
        ...state,
        items: [...state.items, action.item],
        total: state.total + action.item.price
      }
    case 'APPLY_DISCOUNT':
      return {
        ...state,
        discount: action.amount,
        loading: false
      }
    default:
      return state
  }
}

function ShoppingCart() {
  const [state, dispatch] = useReducer(cartReducer, initialState)

  function addItem(item: Item) {
    dispatch({ type: 'ADD_ITEM', item })
  }
}
// All state transitions in one place, testable, predictable
```
