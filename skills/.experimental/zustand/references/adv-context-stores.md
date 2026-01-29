---
title: Combine Zustand with React Context for Dependency Injection
impact: LOW
impactDescription: enables testing, per-subtree stores, SSR isolation
tags: adv, context, dependency-injection, testing
---

## Combine Zustand with React Context for Dependency Injection

Use React Context to provide store instances instead of global singletons. This enables per-component-tree state, easier testing, and SSR isolation.

**Incorrect (global singleton, hard to test):**

```typescript
// Global store - all tests share state
const useCounterStore = create<CounterState>((set) => ({
  count: 0,
  increment: () => set((s) => ({ count: s.count + 1 })),
}))

// Tests leak state between each other
test('counter starts at 0', () => {
  // Previous test's state might still be here
  expect(useCounterStore.getState().count).toBe(0)
})
```

**Correct (context-provided store):**

```typescript
import { createContext, useContext, useRef } from 'react'
import { createStore, useStore } from 'zustand'

// Store factory function
const createCounterStore = (initialCount = 0) =>
  createStore<CounterState>((set) => ({
    count: initialCount,
    increment: () => set((s) => ({ count: s.count + 1 })),
  }))

type CounterStore = ReturnType<typeof createCounterStore>

// Context for store instance
const CounterContext = createContext<CounterStore | null>(null)

// Provider creates isolated store instance
function CounterProvider({
  children,
  initialCount = 0,
}: {
  children: React.ReactNode
  initialCount?: number
}) {
  const storeRef = useRef<CounterStore>()
  if (!storeRef.current) {
    storeRef.current = createCounterStore(initialCount)
  }
  return (
    <CounterContext.Provider value={storeRef.current}>
      {children}
    </CounterContext.Provider>
  )
}

// Hook to access store from context
function useCounterStore<T>(selector: (state: CounterState) => T): T {
  const store = useContext(CounterContext)
  if (!store) throw new Error('Missing CounterProvider')
  return useStore(store, selector)
}

// Usage - each Provider has isolated state
function App() {
  return (
    <>
      <CounterProvider initialCount={0}>
        <Counter /> {/* This counter is independent */}
      </CounterProvider>
      <CounterProvider initialCount={100}>
        <Counter /> {/* This counter starts at 100 */}
      </CounterProvider>
    </>
  )
}
```

**When NOT to use this pattern:**
- Simple apps where global singleton behavior is desired
- When you don't need multiple independent store instances
- When Context provider overhead is not justified for your use case

**Benefits:**
- Easy testing with fresh store per test
- Multiple independent store instances in one app
- SSR: each request gets isolated state
- Dependency injection for store configuration

Reference: [TkDodo - Zustand and React Context](https://tkdodo.eu/blog/zustand-and-react-context)
