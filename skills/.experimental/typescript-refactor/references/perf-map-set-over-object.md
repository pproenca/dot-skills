---
title: Use Map and Set Over Plain Objects for Dynamic Collections
impact: MEDIUM
impactDescription: O(1) operations with better memory and iteration performance
tags: perf, map, set, collections, performance
---

## Use Map and Set Over Plain Objects for Dynamic Collections

Plain objects used as dictionaries have string-only keys, prototype pollution risks, and slower iteration. `Map` and `Set` provide O(1) operations with any key type, guaranteed insertion order, and better memory characteristics for frequently changing collections.

**Incorrect (plain object as dictionary):**

```typescript
const userSessions: Record<string, Session> = {}

function addSession(userId: string, session: Session) {
  userSessions[userId] = session
}

function getSession(userId: string): Session | undefined {
  return userSessions[userId] // No distinction between "missing" and "set to undefined"
}

function countSessions(): number {
  return Object.keys(userSessions).length // Creates intermediate array
}
```

**Correct (Map for typed key-value collections):**

```typescript
const userSessions = new Map<string, Session>()

function addSession(userId: string, session: Session) {
  userSessions.set(userId, session)
}

function getSession(userId: string): Session | undefined {
  return userSessions.get(userId)
}

function countSessions(): number {
  return userSessions.size // O(1), no intermediate array
}
```

**Benefits:**
- Any key type (objects, symbols, numbers — not just strings)
- `.size` is O(1) vs `Object.keys().length` which is O(n)
- No prototype pollution risk
- Guaranteed iteration order
