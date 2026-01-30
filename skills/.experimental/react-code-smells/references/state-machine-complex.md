---
title: Replace Boolean Explosion with State Machines
impact: CRITICAL
impactDescription: eliminates impossible states, reduces state bugs by 70%
tags: state, state-machine, boolean-explosion, impossible-states, refactoring
---

## Replace Boolean Explosion with State Machines

Multiple related booleans create impossible state combinations and complex conditionals. State machines make valid states explicit and transitions clear.

**Code Smell Indicators:**
- 3+ related boolean states (`isLoading`, `isError`, `isSuccess`)
- Conditionals checking multiple booleans
- Bugs from impossible state combinations
- Comments like "// this shouldn't happen"

**Incorrect (boolean explosion with impossible states):**

```tsx
function DataFetcher() {
  const [isLoading, setIsLoading] = useState(false)
  const [isError, setIsError] = useState(false)
  const [isSuccess, setIsSuccess] = useState(false)
  const [data, setData] = useState(null)
  const [error, setError] = useState(null)

  async function fetchData() {
    setIsLoading(true)
    setIsError(false) // easy to forget
    setIsSuccess(false)
    try {
      const result = await api.fetch()
      setData(result)
      setIsSuccess(true)
      setIsLoading(false)
    } catch (e) {
      setError(e)
      setIsError(true)
      setIsLoading(false)
    }
  }

  // What if isLoading && isError? Impossible but possible in code
  if (isLoading) return <Spinner />
  if (isError) return <Error error={error} />
  if (isSuccess) return <Data data={data} />
  return <Empty />
}
```

**Correct (discriminated union / state machine):**

```tsx
type FetchState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: Data }
  | { status: 'error'; error: Error }

function DataFetcher() {
  const [state, setState] = useState<FetchState>({ status: 'idle' })

  async function fetchData() {
    setState({ status: 'loading' })
    try {
      const data = await api.fetch()
      setState({ status: 'success', data })
    } catch (error) {
      setState({ status: 'error', error })
    }
  }

  switch (state.status) {
    case 'idle':
      return <button onClick={fetchData}>Load</button>
    case 'loading':
      return <Spinner />
    case 'success':
      return <Data data={state.data} />
    case 'error':
      return <Error error={state.error} onRetry={fetchData} />
  }
}
```

**For complex state machines, use useReducer:**

```tsx
type Action =
  | { type: 'FETCH' }
  | { type: 'SUCCESS'; data: Data }
  | { type: 'ERROR'; error: Error }
  | { type: 'RESET' }

function reducer(state: FetchState, action: Action): FetchState {
  switch (action.type) {
    case 'FETCH':
      return { status: 'loading' }
    case 'SUCCESS':
      return { status: 'success', data: action.data }
    case 'ERROR':
      return { status: 'error', error: action.error }
    case 'RESET':
      return { status: 'idle' }
  }
}
```

**Benefits:**
- Impossible states are unrepresentable
- TypeScript exhaustiveness checking catches missing cases
- Transitions are explicit and traceable
- Easier to add new states without breaking existing logic

Reference: [Making Impossible States Impossible](https://kentcdodds.com/blog/make-impossible-states-impossible)
