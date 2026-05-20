---
title: Compute Neighbours with the Canonical Border and Neighbour Tables
impact: HIGH
impactDescription: prevents wrong-cell adjacency at all 4 edges
tags: nbr, adjacency, lookup-table, borders, algorithm
---

## Compute Neighbours with the Canonical Border and Neighbour Tables

Adjacency cannot be done by incrementing the last base32 character — the Z-order curve means the cell to the east is not the next character in the alphabet. The de-facto algorithm (David Troy's geohash-js) uses two tables: `NEIGHBORS` maps each character to its neighbour in a direction, and `BORDERS` marks the characters on the edge of the parent cell, where you must recurse into the parent to carry. Hand-rolling adjacency almost always gets the carry wrong; use the proven tables. Note the parity flip: the table you index depends on whether the hash length is odd or even, because the lon/lat bit roles swap each character.

**Incorrect (increment the last character):**

```typescript
// "u" + 1 is NOT the cell to the east — base32 order != spatial order.
function eastNeighbor(hash: string): string {
  const last = hash[hash.length - 1];
  const next = GEOHASH_BASE32[(GEOHASH_BASE32.indexOf(last) + 1) % 32];
  return hash.slice(0, -1) + next; // wrong cell, often a different latitude band
}
```

**Correct (canonical tables with carry recursion):**

```typescript
const NEIGHBORS = {
  north: { even: "p0r21436x8zb9dcf5h7kjnmqesgutwvy", odd: "bc01fg45238967deuvhjyznpkmstqrwx" },
  south: { even: "14365h7k9dcfesgujnmqp0r2twvyx8zb", odd: "238967debc01fg45kmstqrwxuvhjyznp" },
  east:  { even: "bc01fg45238967deuvhjyznpkmstqrwx", odd: "p0r21436x8zb9dcf5h7kjnmqesgutwvy" },
  west:  { even: "238967debc01fg45kmstqrwxuvhjyznp", odd: "14365h7k9dcfesgujnmqp0r2twvyx8zb" },
};
const BORDERS = {
  north: { even: "prxz", odd: "bcfguvyz" },
  south: { even: "028b", odd: "0145hjnp" },
  east:  { even: "bcfguvyz", odd: "prxz" },
  west:  { even: "0145hjnp", odd: "028b" },
};

function adjacent(hash: string, dir: keyof typeof NEIGHBORS): string {
  hash = hash.toLowerCase();
  const last = hash[hash.length - 1];
  const type = hash.length % 2 === 1 ? "odd" : "even"; // parity selects the table
  let base = hash.slice(0, -1);
  if (BORDERS[dir][type].includes(last)) base = adjacent(base, dir); // carry into parent
  return base + GEOHASH_BASE32[NEIGHBORS[dir][type].indexOf(last)];
}
```

**When NOT to apply:**
- If you store geohashes as integers, adjacency is cheaper at the bit level ([[nbr-integer-level-neighbors]]); the string tables are for string geohashes.

Reference: [davetroy/geohash-js](https://github.com/davetroy/geohash-js); [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash)
