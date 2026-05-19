---
title: Build Typed Event Emitters with Mapped Event Maps
impact: CRITICAL
impactDescription: prevents 100% of event-name typos and payload-shape drift at compile time
tags: dsl, events, mapped-types, library-design, pub-sub
---

## Build Typed Event Emitters with Mapped Event Maps

A `string`-keyed event emitter offers zero protection: a typo in the event name silently registers a listener that never fires, and the handler's `payload: any` lets every consumer drift independently. Typing the emitter by an event map — a record where each key is an event name and each value is the payload type — propagates the contract through `on`, `off`, and `emit`. Every call site is checked against one source of truth.

**Incorrect (string events, untyped payloads):**

```typescript
class Emitter {
  private listeners = new Map<string, Array<(payload: unknown) => void>>()

  on(event: string, handler: (payload: unknown) => void) {
    this.listeners.set(event, [...(this.listeners.get(event) ?? []), handler])
  }

  emit(event: string, payload: unknown) {
    for (const h of this.listeners.get(event) ?? []) h(payload)
  }
}

const bus = new Emitter()
bus.on('user:loggedIn', (p) => console.log((p as { userId: string }).userId))
bus.emit('user:loggedin', { userId: 'u_1' }) // Silent typo: listener never fires.
bus.emit('user:loggedIn', { id: 'u_1' })     // Compiles. Crashes at first listener.
```

**Correct (event map drives both `on` and `emit`):**

```typescript
interface AppEvents {
  'user:loggedIn':  { userId: string; sessionId: string }
  'user:loggedOut': { userId: string; reason: 'manual' | 'timeout' }
  'cart:itemAdded': { sku: string; quantity: number }
}

class TypedEmitter<E extends Record<string, unknown>> {
  private listeners: { [K in keyof E]?: Array<(payload: E[K]) => void> } = {}

  on<K extends keyof E>(event: K, handler: (payload: E[K]) => void): void {
    (this.listeners[event] ??= []).push(handler)
  }

  emit<K extends keyof E>(event: K, payload: E[K]): void {
    for (const h of this.listeners[event] ?? []) h(payload)
  }
}

const bus = new TypedEmitter<AppEvents>()
bus.on('user:loggedIn', ({ userId }) => console.log(userId)) // payload inferred as { userId, sessionId }
bus.emit('user:loggedin', { userId: 'u_1', sessionId: 's' }) // Error: 'user:loggedin' is not a known event.
bus.emit('user:loggedIn', { userId: 'u_1' })                 // Error: missing 'sessionId'.
```

Autocomplete now lists all valid event names, and each handler's payload is the exact shape declared in the map.

**When NOT to apply:**
- Dynamic event names known only at runtime (plugin systems, user-defined events) — the map approach can't represent them.
- Cross-process events where TypeScript can't see both ends of the channel; rely on schema validation at the boundary instead.

**Scope delta:**
- This pattern composes cleanly with `[[dsl-schema-first-inference]]`: derive `AppEvents` from runtime schemas so the emitter rejects malformed payloads at the source.

Reference: [TypeScript Handbook — Mapped Types](https://www.typescriptlang.org/docs/handbook/2/mapped-types.html)
