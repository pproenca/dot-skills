---
title: Preserve Side Effects (Logging, I/O, State Changes)
impact: CRITICAL
impactDescription: Missing logs break debugging, altered I/O corrupts data, changed state mutations cause race conditions
tags: behave, side-effects, logging, io, state
---

## Preserve Side Effects (Logging, I/O, State Changes)

Side effects are often the most important part of a function. Logging enables debugging and auditing. I/O operations persist data. State mutations coordinate systems. Removing or reordering side effects during simplification can cause silent failures that only surface in production.

**Incorrect (removes logging side effect):**

```typescript
// Before: logs for audit trail
async function transferFunds(from: Account, to: Account, amount: number) {
  logger.info(`Transfer initiated: ${from.id} -> ${to.id}, amount: ${amount}`);
  await from.debit(amount);
  await to.credit(amount);
  logger.info(`Transfer completed: ${from.id} -> ${to.id}`);
}

// After "simplification": removed "noisy" logging
async function transferFunds(from: Account, to: Account, amount: number) {
  await from.debit(amount);
  await to.credit(amount);
}
// Breaks: audit compliance, debugging capability
```

**Correct (preserve all logging):**

```typescript
async function transferFunds(from: Account, to: Account, amount: number) {
  logger.info(`Transfer initiated: ${from.id} -> ${to.id}, amount: ${amount}`);
  await from.debit(amount);
  await to.credit(amount);
  logger.info(`Transfer completed: ${from.id} -> ${to.id}`);
}
```

**Incorrect (changes I/O timing):**

```python
# Before: writes happen in sequence
def save_order(order: Order) -> None:
    db.save(order)
    cache.invalidate(f"order:{order.id}")
    search_index.update(order)

# After "simplification": parallel writes
async def save_order(order: Order) -> None:
    await asyncio.gather(
        db.save(order),
        cache.invalidate(f"order:{order.id}"),
        search_index.update(order)
    )
# Breaks: cache invalidation may happen before db.save completes
```

**Correct (preserve operation order):**

```python
def save_order(order: Order) -> None:
    db.save(order)
    cache.invalidate(f"order:{order.id}")
    search_index.update(order)
```

**Incorrect (changes state mutation order):**

```go
// Before: specific mutation order
func (s *Server) Shutdown() {
    s.mu.Lock()
    s.accepting = false
    s.mu.Unlock()
    s.drainConnections()
    s.closeListeners()
}

// After "simplification": reordered
func (s *Server) Shutdown() {
    s.closeListeners()  // Moved up
    s.mu.Lock()
    s.accepting = false
    s.mu.Unlock()
    s.drainConnections()
}
// Breaks: new connections may be accepted after listeners closed
```

**Correct (preserve mutation order):**

```go
func (s *Server) Shutdown() {
    s.mu.Lock()
    s.accepting = false
    s.mu.Unlock()
    s.drainConnections()
    s.closeListeners()
}
```

### Benefits

- Debugging and monitoring capabilities preserved
- Data consistency maintained
- Race conditions avoided
- Audit trails remain intact
