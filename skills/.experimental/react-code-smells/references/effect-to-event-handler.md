---
title: Move Event Responses from Effects to Handlers
impact: MEDIUM
impactDescription: eliminates unnecessary effect complexity, prevents timing bugs
tags: effect, event-handlers, synchronization, refactoring
---

## Move Event Responses from Effects to Handlers

Effects are for synchronizing with external systems, not responding to events. Move event-driven logic to event handlers.

**Code Smell Indicators:**
- Effect that runs only after a specific user action
- Effect with a boolean flag to track "should run"
- Unnecessary state to bridge event → effect
- Effect immediately after user interaction

**Incorrect (effect for event response):**

```tsx
function SearchForm() {
  const [query, setQuery] = useState('')
  const [shouldSearch, setShouldSearch] = useState(false)
  const [results, setResults] = useState([])

  // Effect responds to search button click - wrong pattern
  useEffect(() => {
    if (shouldSearch) {
      search(query).then(setResults)
      setShouldSearch(false)  // Reset flag
    }
  }, [shouldSearch, query])

  function handleSubmit(e) {
    e.preventDefault()
    setShouldSearch(true)  // Trigger effect indirectly
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={query} onChange={e => setQuery(e.target.value)} />
      <button type="submit">Search</button>
      <Results results={results} />
    </form>
  )
}
```

**Correct (event handler directly):**

```tsx
function SearchForm() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])

  // Event handler - responds to user action directly
  async function handleSubmit(e) {
    e.preventDefault()
    const data = await search(query)
    setResults(data)
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={query} onChange={e => setQuery(e.target.value)} />
      <button type="submit">Search</button>
      <Results results={results} />
    </form>
  )
}
```

**Effect IS correct for synchronization:**

```tsx
function ChatRoom({ roomId }) {
  const [messages, setMessages] = useState([])

  // Effect: synchronize with external system (WebSocket)
  useEffect(() => {
    const connection = createConnection(roomId)
    connection.on('message', msg => setMessages(prev => [...prev, msg]))

    // Cleanup when roomId changes or component unmounts
    return () => connection.disconnect()
  }, [roomId])

  // Event handler: respond to user sending message
  function handleSend(text) {
    sendMessage(roomId, text)  // Not in effect, direct response to action
  }

  return (
    <div>
      <MessageList messages={messages} />
      <MessageInput onSend={handleSend} />
    </div>
  )
}
```

**Decision framework:**

```
What triggers this code?
├── User action (click, submit, type)? → Event handler
├── Prop/state change needing sync? → Effect
├── Component mount? → Effect (if external sync needed)
└── External system event? → Effect subscription
```

**Before/After pattern:**

```tsx
// BEFORE: Effect triggered by flag
const [shouldSubmit, setShouldSubmit] = useState(false)
useEffect(() => {
  if (shouldSubmit) {
    submitForm(data).then(handleSuccess)
    setShouldSubmit(false)
  }
}, [shouldSubmit, data])

const handleClick = () => setShouldSubmit(true)

// AFTER: Direct event handler
const handleClick = async () => {
  await submitForm(data)
  handleSuccess()
}
```

Reference: [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
