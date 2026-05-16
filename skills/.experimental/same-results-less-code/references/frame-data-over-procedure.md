---
title: Model the Problem as Data Before Writing Procedure
impact: CRITICAL
impactDescription: reduces 50-200 lines of branches to a small table plus one interpreter
tags: frame, data-driven, modelling
---

## Model the Problem as Data Before Writing Procedure

When a function grows long because it has many cases, each requiring its own branch, the cases are usually *data*, not code. The cure is to write down the cases as a table, list, or graph, and then write *one* small piece of code that interprets that data. The result is shorter, easier to extend (new case = new row), easier to test (parameterise on rows), and easier to read (one mechanism, many configs).

**Incorrect (each shipping method is a branch in one growing procedure):**

```typescript
function calculateShipping(method: string, weight: number, country: string): number {
  if (method === 'standard' && country === 'US') {
    return weight < 1 ? 4.99 : weight < 5 ? 9.99 : 19.99;
  }
  if (method === 'standard' && country === 'EU') {
    return weight < 1 ? 6.99 : weight < 5 ? 14.99 : 29.99;
  }
  if (method === 'express' && country === 'US') {
    return weight < 1 ? 14.99 : weight < 5 ? 24.99 : 49.99;
  }
  if (method === 'express' && country === 'EU') {
    return weight < 1 ? 19.99 : weight < 5 ? 34.99 : 59.99;
  }
  if (method === 'overnight' && country === 'US') {
    return weight < 1 ? 29.99 : weight < 5 ? 49.99 : 99.99;
  }
  // ...continues for every method × country × weight tier. Add a country: edit every branch.
  throw new Error('Unsupported');
}
```

**Correct (the cases are data; the procedure is one tiny interpreter):**

```typescript
type Tier = { maxWeight: number; price: number };
type Region = { country: string; method: string; tiers: Tier[] };

const RATES: Region[] = [
  { country: 'US', method: 'standard',  tiers: [{ maxWeight: 1, price: 4.99 },  { maxWeight: 5, price: 9.99 },  { maxWeight: Infinity, price: 19.99 }] },
  { country: 'EU', method: 'standard',  tiers: [{ maxWeight: 1, price: 6.99 },  { maxWeight: 5, price: 14.99 }, { maxWeight: Infinity, price: 29.99 }] },
  { country: 'US', method: 'express',   tiers: [{ maxWeight: 1, price: 14.99 }, { maxWeight: 5, price: 24.99 }, { maxWeight: Infinity, price: 49.99 }] },
  { country: 'EU', method: 'express',   tiers: [{ maxWeight: 1, price: 19.99 }, { maxWeight: 5, price: 34.99 }, { maxWeight: Infinity, price: 59.99 }] },
  { country: 'US', method: 'overnight', tiers: [{ maxWeight: 1, price: 29.99 }, { maxWeight: 5, price: 49.99 }, { maxWeight: Infinity, price: 99.99 }] },
];

function calculateShipping(method: string, weight: number, country: string): number {
  const region = RATES.find(r => r.country === country && r.method === method);
  if (!region) throw new Error('Unsupported');
  return region.tiers.find(t => weight < t.maxWeight)!.price;
}
// New region → one new row. New tier rule → change the interpreter once.
// The procedure is 3 lines. The data carries the variability.
```

**Cues that procedure should be data:**

- The function is long, but every branch has the same *shape* (lookup → return).
- Adding a new case means copy-pasting an existing branch and changing literals.
- Tests for the function are mostly checking that each branch returns the right constant.
- You can describe the function's behaviour as "for each X, do Y" — that's a table.

**When NOT to use this pattern:**

- The cases truly differ in *behaviour*, not just values — e.g. one branch calls a different external service, another writes to a different table. Then they're real cases, not table rows. (Though even then, a discriminated union may be cleaner than a long if-chain.)
- There are only two or three cases and they're never going to grow. Don't over-engineer for hypothetical extension.

Reference: [Tidy First? — Replace Conditional With Map](https://tidyfirst.substack.com/) (Kent Beck)
