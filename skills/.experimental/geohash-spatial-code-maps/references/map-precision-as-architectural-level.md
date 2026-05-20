---
title: Map Prefix Length to Architectural Level
impact: HIGH
impactDescription: prevents inconsistent prefix semantics across call sites
tags: map, precision, hierarchy, architecture, addressing
---

## Map Prefix Length to Architectural Level

A geohash gets more specific one character at a time, which fits architectural nesting naturally: a short prefix addresses a whole domain, a longer one a module, longer still a file, and the full hash a symbol. Fix this length-to-level mapping up front so every scale has a stable address — you can link to "the Billing domain" (length 3) or "this function" (length 12) and the link keeps meaning. Without a fixed mapping, prefixes have no consistent semantic and navigation is guesswork.

**Incorrect (ad-hoc lengths per call site):**

```typescript
const domainView = group(map, 5);   // 5 here...
const moduleView = group(map, 6);   // ...6 there, with no shared meaning
const fileLink = map.geohash(file).slice(0, 7); // and 7 elsewhere
```

**Correct (one declared level table):**

```typescript
const LEVELS = { domain: 3, module: 5, file: 8, symbol: 12 } as const;
type Level = keyof typeof LEVELS;

function addressAt(file: string, level: Level, map: CodeMap): string {
  return map.geohash(file).slice(0, LEVELS[level]); // stable address per level
}

const billingDomain = addressAt(file, "domain", map); // length 3, always
```

This semantic mapping (what a prefix length *means*) is distinct from the rendering zoom levels in [[nav-precision-to-zoom-levels]] (what you *show* at each zoom).

**When NOT to apply:**
- If your codebase has fewer architectural tiers than geohash characters allow, collapse unused levels rather than inventing tiers to fill them.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash); [CodeCity — Wettel & Lanza](https://wettel.github.io/codecity.html)
