---
title: Avoid Promise.all on writes — SQLite is single-writer
impact: MEDIUM-HIGH
impactDescription: prevents lock contention disguised as parallelism
tags: tx, single-writer, parallel, promise-all
---

## Avoid Promise.all on writes — SQLite is single-writer

`Promise.all([insert1, insert2, insert3])` looks like parallelism but SQLite serializes the write lock. Two writes can't actually run concurrently — one takes the lock, the others wait, and you've added contention without saving any time. Worse, with `deferred` transactions (the default), two parallel transactions can deadlock: A holds the read lock and tries to upgrade, B does too, neither yields. Read queries against WAL **can** run in parallel with each other and with one writer — but parallelism within writes themselves is a myth.

**Incorrect (Promise.all writes — contention, possibly deadlock):**

```typescript
// ☠️ Three parallel transactions that all want to write —
//    they queue serially at best, deadlock at worst.
await Promise.all([
  db.transaction(async (tx) => {
    await tx.insert(events).values({ kind: 'login', userId: 1 });
  }),
  db.transaction(async (tx) => {
    await tx.insert(events).values({ kind: 'click', userId: 1 });
  }),
  db.transaction(async (tx) => {
    await tx.update(users).set({ lastSeen: new Date() }).where(eq(users.id, 1));
  }),
]);
```

**Correct (sequential or batched — explicit about the constraint):**

```typescript
// Sequential — clean, no contention:
await db.transaction(async (tx) => {
  await tx.insert(events).values({ kind: 'login', userId: 1 });
  await tx.insert(events).values({ kind: 'click', userId: 1 });
  await tx.update(users).set({ lastSeen: new Date() }).where(eq(users.id, 1));
});

// Or a multi-row insert when statements have the same shape:
await db.insert(events).values([
  { kind: 'login', userId: 1 },
  { kind: 'click', userId: 1 },
]);
```

**Parallel reads are fine when WAL is enabled:**

```typescript
// ✅ With journal_mode=WAL, readers don't block readers and don't block the writer.
const [user, posts, comments] = await Promise.all([
  db.select().from(users).where(eq(users.id, userId)),
  db.select().from(posts).where(eq(posts.authorId, userId)).limit(10),
  db.select().from(comments).where(eq(comments.userId, userId)).limit(10),
]);
```

**Parallel read + write is also fine in WAL — but the write still serializes against other writers, not against readers.**

**For cross-process write contention, the only fixes are:**
- WAL mode + `busy_timeout` to handle inter-process queueing gracefully.
- Sharding the write load across multiple SQLite files (per-tenant databases).
- A single writer process funneling writes from N reader processes.

Reference: [SQLite — File locking and concurrency](https://www.sqlite.org/lockingv3.html) · [SQLite — WAL](https://www.sqlite.org/wal.html)
