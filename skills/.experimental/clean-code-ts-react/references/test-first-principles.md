---
title: Apply FIRST Principles to Tests
impact: MEDIUM
impactDescription: Fast, isolated, deterministic tests get run; slow flaky ones get skipped
tags: test, first, ci, determinism
---

## Apply FIRST Principles to Tests

Tests should be **Fast**, **Independent**, **Repeatable**, **Self-validating**, and **Timely**. A 30-second test won't run on every save. A test that depends on another test's leftover data gets skipped in parallel CI. A test that prints output for a human to eyeball doesn't catch regressions overnight. Each broken letter compounds.

**Incorrect (slow, order-dependent, manually verified):**

```ts
import { describe, test } from 'vitest';
import { db } from './db';

// Slow: spins up a real Postgres container.
// Not Independent: relies on the Order created by the previous test.
// Not Self-validating: prints output for the human to inspect.
describe('OrderService', () => {
  test('creates order', async () => {
    const order = await db.orders.insert({ customerId: 'c-1', total: 99 });
    console.log('created', order);
  });

  test('finds order by customer', async () => {
    const found = await db.orders.findByCustomer('c-1');
    console.log('found', found); // human verifies
  });
});
```

**Correct (in-memory, isolated fixtures, real assertions):**

```ts
import { beforeEach, describe, expect, test } from 'vitest';
import { createTestDb, type TestDb } from './testing/createTestDb';
import { OrderService } from './OrderService';

describe('OrderService', () => {
  let db: TestDb;
  let service: OrderService;

  beforeEach(() => {
    // Fresh in-memory DB per test => Fast, Independent, Repeatable.
    db = createTestDb();
    service = new OrderService(db);
  });

  test('creates order with given total', async () => {
    const order = await service.create({ customerId: 'c-1', total: 99 });
    expect(order.total).toBe(99); // Self-validating.
  });

  test('finds order by customer', async () => {
    await service.create({ customerId: 'c-1', total: 99 });
    const found = await service.findByCustomer('c-1');
    expect(found).toHaveLength(1);
  });
});
```

**When NOT to apply this pattern:**
- True end-to-end / smoke tests that exercise the whole stack are slow and may share state by design — accept that, and keep them as ONE layer of the pyramid, not the only layer.
- Chaos and flake-reproducer tests deliberately violate Repeatable to surface non-determinism — they live in a separate suite.
- Performance benchmarks that must run against a warm system intentionally relax Independent and Fast — isolate them from your unit suite.

**Why this matters:** FIRST isn't five separate rules; it's one rule about feedback. Anything that makes the feedback slow or noisy reduces the test's value to near zero.

Reference: [Clean Code, Chapter 9: Unit Tests](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
