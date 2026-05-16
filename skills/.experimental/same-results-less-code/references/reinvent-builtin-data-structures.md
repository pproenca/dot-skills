---
title: Recognise When a Custom Container Is Just a Map, Set, or Queue
impact: CRITICAL
impactDescription: eliminates 50-200 line wrapper classes around Map, Set, or Deque
tags: reinvent, data-structures, stdlib, collections
---

## Recognise When a Custom Container Is Just a Map, Set, or Queue

When a class's job is "store things by key and let me get them back," it's a `Map`. When it's "track membership," it's a `Set`. When it's "first in, first out," a deque or array works. A surprising amount of code volume comes from `Registry`, `Cache`, `Lookup`, and `Index` classes whose entire surface area is already on `Map`. The class wrapper adds nothing except a name — and it hides the underlying operations so future readers can't see them.

**Incorrect (a class that wraps a Map and exposes the same operations):**

```typescript
class UserRegistry {
  private users: Map<string, User> = new Map();

  register(id: string, user: User): void { this.users.set(id, user); }
  get(id: string): User | undefined    { return this.users.get(id); }
  has(id: string): boolean              { return this.users.has(id); }
  remove(id: string): void              { this.users.delete(id); }
  all(): User[]                         { return Array.from(this.users.values()); }
  // The class is a no-op wrapper. Every method is a rename of the Map method.
}
```

**Correct (use the Map directly, or a type alias if you want documentation):**

```typescript
type UserRegistry = Map<string, User>;

const users: UserRegistry = new Map();
users.set(id, user);
users.get(id);
// Same operations, no rebuild. The type alias documents intent without writing methods.
```

**If the class actually adds behaviour, keep it — but slim it:**

```typescript
class UserRegistry extends Map<string, User> {
  registerIfAbsent(id: string, factory: () => User): User {
    let u = this.get(id);
    if (!u) { u = factory(); this.set(id, u); }
    return u;
    // This method earns its place — it's not in Map. Everything else stayed Map's.
  }
}
```

**Other cases:**

- A `UniqueList` that "stores items only once" → `Set`.
- A `TaskQueue` whose API is `push` + `pop_front` → an array or `Deque`.
- A `PriorityList` sorted on every insert → a heap (`heapq` in Python, `js-priority-queue`).
- A `Counter` that tracks frequencies → `new Map<K, number>()` or `collections.Counter`.

**When NOT to use this pattern:**

- The class enforces an invariant the stdlib type can't — e.g. "always non-empty," "values normalised on insert." Then the class adds value. Keep it, but make it minimal.

Reference: [MDN — Map](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map)
