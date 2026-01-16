---
title: Design Idempotent Tool Operations
impact: MEDIUM
impactDescription: prevents duplicate side effects from retries
tags: mcp, idempotent, reliability, retries
---

## Design Idempotent Tool Operations

Design MCP tools so calling them multiple times with the same input produces the same result. Claude may retry failed calls, and network issues can cause duplicate requests. Non-idempotent tools create inconsistent state.

**Incorrect (non-idempotent increment):**

```typescript
// Tool: increment_counter
async function incrementCounter(counterId: string): Promise<number> {
  const counter = await db.get(counterId)
  counter.value += 1
  await db.save(counter)
  return counter.value
}
```

```text
# User asks to increment counter
# Claude calls tool, network timeout
# Claude retries (same request)
# Counter incremented twice!
# Value is now 2 instead of 1
```

**Correct (idempotent set with request ID):**

```typescript
// Tool: set_counter
async function setCounter(
  counterId: string,
  value: number,
  requestId: string
): Promise<number> {
  const existing = await db.getByRequestId(requestId)
  if (existing) {
    return existing.value  // Already processed
  }

  await db.save({ counterId, value, requestId })
  return value
}
```

```text
# User asks to set counter to 5
# Claude calls tool, network timeout
# Claude retries with same requestId
# Tool detects duplicate, returns existing value
# Counter is exactly 5
```

**Idempotency strategies:**
| Operation | Strategy |
|-----------|----------|
| Create | Use client-provided ID or check existence |
| Update | Use PUT semantics (replace entire state) |
| Delete | Return success even if already deleted |
| Increment | Accept absolute value instead of delta |

Reference: [MCP Best Practices](https://modelcontextprotocol.info/docs/best-practices/)
