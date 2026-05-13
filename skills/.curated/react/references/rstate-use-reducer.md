---
title: Coordinated multi-field state transitions live in a single reducer — not in N sibling `useState` cells
impact: MEDIUM
impactDescription: eliminates "forgot to update one of three setters" bugs, makes state transitions unit-testable, removes invalid-combination states
tags: rstate, reducer-extraction, multi-field-state, action-shape
---

## Coordinated multi-field state transitions live in a single reducer — not in N sibling `useState` cells

**Pattern intent:** when N pieces of state co-evolve (cart items + total + discount + loading), the *transitions* between configurations are the real abstraction. A reducer expresses them as named actions, makes them testable in isolation, and makes invalid combinations representable-or-not by typing.

### Shapes to recognize

- A component with 4+ `useState` calls whose handlers always update multiple cells together.
- An event handler that calls `setItems(...)`, `setTotal(...)`, `setDiscount(...)` in sequence — easy to add a fifth state cell and forget to update it everywhere.
- "Impossible states" appearing in dev: loading is true but data is also non-null; error is set but success is too.
- A custom hook with `useState` + a wrapper API that's effectively a reducer in disguise (every wrapper function reads the cells and writes new ones).
- An onboarding/wizard component with a `step` cell, a `data` cell, and a `validation` cell — should be one `useReducer` whose state is a discriminated union of step variants.

The canonical resolution: define a state type and an action union; write a `cartReducer(state, action)` switching on `action.type`; `const [state, dispatch] = useReducer(reducer, initial)`. Transitions become named, testable, and exhaustive.

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
