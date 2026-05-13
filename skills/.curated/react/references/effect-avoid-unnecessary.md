---
title: useEffect is for syncing with external systems — never for derived state, mutations, event logic, parent notification, or app init
impact: HIGH
impactDescription: eliminates extra render passes, sync bugs, stale closures, and chained-effect cascades; collapses six common anti-patterns to their canonical resolutions
tags: effect, effect-misuse-taxonomy, derived-state, event-logic, lift-state
---

## useEffect is for syncing with external systems — never for derived state, mutations, event logic, parent notification, or app init

**Pattern intent:** `useEffect` is the React-to-outside-world synchronization primitive. It exists for: subscribing to DOM events, opening sockets, calling third-party libraries, observing external stores. Anything else that lives entirely inside React's own model has a non-effect resolution. This rule is the **taxonomy** of the six bad jobs people give `useEffect`.

### The six anti-patterns and their resolutions

| # | Anti-pattern shape | Canonical resolution |
|---|---|---|
| 1 | `useState` + `useEffect` to mirror derived data | Compute in render (see [`rstate-derived-values.md`](rstate-derived-values.md) — that rule is the *detection lens* for this case) |
| 2 | `useEffect` to run logic after a user event (track, log, navigate) | Run inside the event handler |
| 3 | `useEffect` to perform a mutation after `setState` | Mutate in the event handler; for forms use `<form action={serverAction}>` |
| 4 | Chained `useEffect`s where each updates state that triggers the next | Compute the next state in the triggering event |
| 5 | `useEffect` to notify the parent of state change | Lift state up, or call `onChange` in the same event that updated state |
| 6 | `useEffect` for app/module initialization | Run at module scope (or in a framework's app-boot hook) |

### Shapes to recognize

See the cross-reference table above. The shorthand is: *if the body of `useEffect` only touches React state/props and doesn't talk to anything outside React, use a different pattern from the table.*

The original detail (each anti-pattern with full example) follows below.

1. You can calculate the value during render (derived state — see [`rstate-derived-values.md`](rstate-derived-values.md))
2. The work belongs to a user event (mutations, navigation, analytics for actions)
3. You're chaining effects to trigger more state updates
4. You're notifying a parent — lift the state up instead
5. You're initializing the app — do it at module scope
6. You're subscribing to an external store — use `useSyncExternalStore` (see `effect-use-sync-external-store.md`)

---

**Incorrect (effect for derived state):**

```typescript
function Form() {
  const [firstName, setFirstName] = useState('')
  const [lastName, setLastName] = useState('')
  const [fullName, setFullName] = useState('')

  useEffect(() => {
    setFullName(`${firstName} ${lastName}`)
  }, [firstName, lastName])
  // ❌ Extra render, sync hole between updates

  return <input value={fullName} disabled />
}
```

**Correct (calculate during render):**

```typescript
function Form() {
  const [firstName, setFirstName] = useState('')
  const [lastName, setLastName] = useState('')

  const fullName = `${firstName} ${lastName}`  // ✅ Always in sync

  return <input value={fullName} disabled />
}
```

---

**Incorrect (effect to run logic after a user event):**

```typescript
function BuyButton({ product }: { product: Product }) {
  useEffect(() => {
    if (product.wasAddedToCart) {
      trackPurchase(product)  // ❌ Tracking tied to render, not click
    }
  }, [product])
}
```

**Correct (run in the event handler):**

```typescript
function BuyButton({ product }: { product: Product }) {
  function handleClick() {
    addToCart(product)
    trackPurchase(product)  // ✅ Tracking tied to the actual user action
  }

  return <button onClick={handleClick}>Buy</button>
}
```

---

**Incorrect (POSTing in an effect after setting state):**

```typescript
function SignupForm() {
  const [payload, setPayload] = useState<Payload | null>(null)

  useEffect(() => {
    if (payload) post('/api/register', payload)  // ❌
  }, [payload])

  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setPayload({ firstName, lastName })
  }
}
```

**Correct (POST in the event handler — or better, use a form action):**

```typescript
function SignupForm() {
  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault()
    post('/api/register', { firstName, lastName })  // ✅
  }
}
```

Mutations belong to events, not renders. For forms, prefer `<form action={serverAction}>` with `useActionState` (see `form-actions.md`, `form-use-action-state.md`).

---

**Incorrect (chains of effects updating each other):**

```typescript
function Game() {
  const [card, setCard] = useState<Card | null>(null)
  const [goldCardCount, setGoldCardCount] = useState(0)
  const [round, setRound] = useState(1)

  useEffect(() => {
    if (card?.gold) setGoldCardCount(c => c + 1)
  }, [card])

  useEffect(() => {
    if (goldCardCount > 3) {
      setRound(r => r + 1)
      setGoldCardCount(0)
    }
  }, [goldCardCount])
  // ❌ Multiple render passes, brittle to reorder
}
```

**Correct (compute next state inside the triggering event):**

```typescript
function Game() {
  function handlePlaceCard(nextCard: Card) {
    setCard(nextCard)
    if (nextCard.gold) {
      if (goldCardCount < 3) {
        setGoldCardCount(goldCardCount + 1)
      } else {
        setGoldCardCount(0)
        setRound(round + 1)
      }
    }
  }
}
```

---

**Incorrect (effect to notify the parent):**

```typescript
function Toggle({ onChange }: { onChange: (v: boolean) => void }) {
  const [isOn, setIsOn] = useState(false)

  useEffect(() => {
    onChange(isOn)  // ❌ Stale-closure risk, extra render
  }, [isOn, onChange])

  return <button onClick={() => setIsOn(!isOn)}>{isOn ? 'On' : 'Off'}</button>
}
```

**Correct (notify in the same event that updates state, or lift state up):**

```typescript
function Toggle({ isOn, onChange }: { isOn: boolean; onChange: (v: boolean) => void }) {
  // ✅ Fully controlled — parent owns the state
  return <button onClick={() => onChange(!isOn)}>{isOn ? 'On' : 'Off'}</button>
}
```

---

**Incorrect (effect for one-time app initialization):**

```typescript
function App() {
  useEffect(() => {
    loadDataFromLocalStorage()
    checkAuthToken()
  }, [])
  // ❌ Runs twice in StrictMode dev; tied to component mount
}
```

**Correct (run at module scope, once per app load):**

```typescript
if (typeof window !== 'undefined') {
  checkAuthToken()
  loadDataFromLocalStorage()
}

function App() { /* ... */ }
```

---

Reference: [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
