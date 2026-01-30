---
title: Separate Unrelated Effects
impact: MEDIUM
impactDescription: prevents unnecessary re-runs, improves readability
tags: effect, single-responsibility, separation, refactoring
---

## Separate Unrelated Effects

One effect doing multiple unrelated things runs too often and is hard to understand. Split into focused effects.

**Code Smell Indicators:**
- Effect with many unrelated operations
- Changing one dependency triggers unrelated code
- Effect has multiple independent cleanup functions
- Can't describe what the effect does in one sentence

**Incorrect (combined unrelated effects):**

```tsx
function UserDashboard({ userId, roomId }) {
  const [user, setUser] = useState(null)
  const [messages, setMessages] = useState([])
  const [isOnline, setIsOnline] = useState(true)

  // One effect doing three unrelated things
  useEffect(() => {
    // Fetch user (depends on userId)
    fetchUser(userId).then(setUser)

    // Subscribe to chat (depends on roomId)
    const chatConnection = subscribeToRoom(roomId, msg => {
      setMessages(prev => [...prev, msg])
    })

    // Subscribe to online status (depends on nothing)
    const onlineCheck = setInterval(() => {
      setIsOnline(navigator.onLine)
    }, 1000)

    return () => {
      chatConnection.close()
      clearInterval(onlineCheck)
    }
  }, [userId, roomId])  // Changing userId re-subscribes to chat unnecessarily!
}
```

**Correct (separated by concern):**

```tsx
function UserDashboard({ userId, roomId }) {
  const [user, setUser] = useState(null)
  const [messages, setMessages] = useState([])
  const [isOnline, setIsOnline] = useState(true)

  // Effect 1: Fetch user data
  useEffect(() => {
    fetchUser(userId).then(setUser)
  }, [userId])

  // Effect 2: Subscribe to chat room
  useEffect(() => {
    const connection = subscribeToRoom(roomId, msg => {
      setMessages(prev => [...prev, msg])
    })
    return () => connection.close()
  }, [roomId])

  // Effect 3: Monitor online status
  useEffect(() => {
    const interval = setInterval(() => {
      setIsOnline(navigator.onLine)
    }, 1000)
    return () => clearInterval(interval)
  }, [])  // No dependencies - runs once

  return (/* ... */)
}
```

**Even better: Extract to custom hooks:**

```tsx
function UserDashboard({ userId, roomId }) {
  const user = useUser(userId)
  const messages = useRoomMessages(roomId)
  const isOnline = useOnlineStatus()

  return (/* ... */)
}

// Each hook encapsulates one synchronization concern
function useUser(userId) {
  const [user, setUser] = useState(null)
  useEffect(() => {
    fetchUser(userId).then(setUser)
  }, [userId])
  return user
}

function useRoomMessages(roomId) {
  const [messages, setMessages] = useState([])
  useEffect(() => {
    const connection = subscribeToRoom(roomId, msg => {
      setMessages(prev => [...prev, msg])
    })
    return () => connection.close()
  }, [roomId])
  return messages
}

function useOnlineStatus() {
  const [isOnline, setIsOnline] = useState(true)
  useEffect(() => {
    const interval = setInterval(() => {
      setIsOnline(navigator.onLine)
    }, 1000)
    return () => clearInterval(interval)
  }, [])
  return isOnline
}
```

**How to identify separation points:**

```
Current effect:
├── Part A depends on [userId]
├── Part B depends on [roomId]
└── Part C depends on []

These should be 3 separate effects because:
- Different dependencies
- Independent lifecycles
- No shared state between parts
```

**Keep effects together when:**
- They share cleanup logic
- One depends on the result of another
- They represent one logical synchronization

Reference: [Separating Events from Effects](https://react.dev/learn/separating-events-from-effects)
