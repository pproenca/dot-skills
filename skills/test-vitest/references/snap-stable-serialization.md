---
title: Ensure Stable Snapshot Serialization
impact: MEDIUM
impactDescription: Eliminates false snapshot failures from non-deterministic data
tags: snap, serialization, deterministic, dates, uuids
---

## Ensure Stable Snapshot Serialization

Snapshots containing dates, random IDs, or other non-deterministic values change on every run. This forces constant snapshot updates and makes tests useless for detecting actual changes.

**Incorrect (unstable data):**

```typescript
import { describe, it, expect } from 'vitest'

describe('OrderSerializer', () => {
  it('should serialize order', () => {
    const order = createOrder({ item: 'Widget' })
    // Snapshot changes every run due to timestamp and ID
    expect(order).toMatchInlineSnapshot(`
      {
        "id": "abc123-def456-...",
        "createdAt": "2024-01-15T10:30:00.000Z",
        "item": "Widget"
      }
    `)
  })
})
```

**Correct (stable serialization):**

```typescript
import { describe, it, expect, vi } from 'vitest'

describe('OrderSerializer', () => {
  it('should serialize order', () => {
    // Fix the date
    vi.setSystemTime(new Date('2024-01-01T00:00:00Z'))

    // Mock ID generation
    vi.spyOn(crypto, 'randomUUID').mockReturnValue('test-uuid-1234')

    const order = createOrder({ item: 'Widget' })
    expect(order).toMatchInlineSnapshot(`
      {
        "id": "test-uuid-1234",
        "createdAt": "2024-01-01T00:00:00.000Z",
        "item": "Widget"
      }
    `)
  })
})
```

**Using property matchers:**

```typescript
describe('OrderSerializer', () => {
  it('should serialize order with dynamic fields', () => {
    const order = createOrder({ item: 'Widget' })

    expect(order).toMatchInlineSnapshot(
      {
        id: expect.any(String),
        createdAt: expect.any(Date),
      },
      `
      {
        "id": Any<String>,
        "createdAt": Any<Date>,
        "item": "Widget"
      }
    `
    )
  })
})
```

**Custom serializers for complex types:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    snapshotSerializers: ['./test/serializers/date-serializer.ts'],
  },
})
```

**Benefits:**
- Snapshots only change when behavior changes
- No false positives from timestamps
- Reliable CI builds

Reference: [Vitest Snapshot Serializers](https://vitest.dev/guide/snapshot#custom-serializers)
