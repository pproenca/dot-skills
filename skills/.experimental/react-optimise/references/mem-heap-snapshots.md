---
title: Use Heap Snapshots to Detect Component Retention
impact: LOW-MEDIUM
impactDescription: eliminates 10-100MB retained memory from component leaks
tags: mem, heap-snapshot, chrome-devtools, detached-dom
---

## Use Heap Snapshots to Detect Component Retention

Detached DOM nodes and retained component closures are invisible in code review. A component that appears to unmount correctly can still be held in memory by a stale event handler, timer, or external reference. Heap snapshot comparison between navigation states reveals exactly which objects are retained and what retains them.

**Incorrect (no leak detection, memory grows silently):**

```tsx
function ChatRoom({ roomId }: { roomId: string }) {
  const [messages, setMessages] = useState<Message[]>([])
  const messagesEndRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const connection = createChatConnection(roomId)

    connection.on("message", (message: Message) => {
      setMessages((prev) => [...prev, message])
      messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
    })

    connection.connect()

    // Missing cleanup — connection holds reference to setMessages closure
    // Navigating between rooms accumulates connections and message arrays
    // No way to detect this without heap analysis
  }, [roomId])

  return (
    <div className="chat-messages">
      {messages.map((msg) => (
        <MessageBubble key={msg.id} message={msg} />
      ))}
      <div ref={messagesEndRef} />
    </div>
  )
}
```

**Correct (heap snapshot workflow to detect and fix retention):**

```tsx
// Step 1: Chrome DevTools → Memory → Take heap snapshot (baseline)
// Step 2: Navigate to ChatRoom, send messages, navigate away
// Step 3: Force garbage collection (trash can icon)
// Step 4: Take second heap snapshot
// Step 5: Select "Comparison" view between snapshots
// Step 6: Filter by "Detached" — find retained ChatRoom DOM nodes
// Step 7: Follow retainer chain to find the leaking reference

// Fix: proper cleanup after identifying the leak via heap snapshot
function ChatRoom({ roomId }: { roomId: string }) {
  const [messages, setMessages] = useState<Message[]>([])
  const messagesEndRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const connection = createChatConnection(roomId)

    connection.on("message", (message: Message) => {
      setMessages((prev) => [...prev, message])
      messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
    })

    connection.connect()

    return () => {
      connection.disconnect() // releases socket, listeners, and closure
    }
  }, [roomId])

  return (
    <div className="chat-messages">
      {messages.map((msg) => (
        <MessageBubble key={msg.id} message={msg} />
      ))}
      <div ref={messagesEndRef} />
    </div>
  )
}

// Verify fix: repeat snapshot comparison — no detached nodes remain
```

Reference: [Chrome DevTools — Record Heap Snapshots](https://developer.chrome.com/docs/devtools/memory-problems/heap-snapshots)
