---
title: Treat a Geohash Prefix as a Named Domain Region
impact: HIGH
impactDescription: prevents brittle path-based domain heuristics
tags: map, domain, region, prefix, labeling
---

## Treat a Geohash Prefix as a Named Domain Region

Once code is geohashed, a prefix is a rectangular region of the map, and "which domain owns this file?" becomes a prefix lookup. Maintain an explicit, ordered registry mapping prefixes to domain labels (longest-prefix-wins, like an IP routing table) so membership, ownership, and boundaries are data you can query and review — not tribal knowledge scattered across CODEOWNERS and folder names. New files get a domain automatically from where they land on the map.

**Incorrect (re-derive domains from paths every time):**

```typescript
function domainOf(file: string): string {
  if (file.includes("/checkout/")) return "Checkout"; // brittle path heuristics
  if (file.includes("/billing/")) return "Billing";
  return "Unknown"; // a moved or new file falls through
}
```

**Correct (longest-prefix match against a region registry):**

```typescript
// Ordered longest-first so the most specific region wins.
const REGIONS: { prefix: string; domain: string }[] = [
  { prefix: "gcpuv", domain: "Checkout / Payments" },
  { prefix: "gcpu",  domain: "Checkout" },
  { prefix: "gcp",   domain: "Commerce" },
].sort((a, b) => b.prefix.length - a.prefix.length);

function domainOf(file: string, map: CodeMap): string {
  const hash = map.geohash(file);
  return REGIONS.find((r) => hash.startsWith(r.prefix))?.domain ?? "Unassigned";
}
```

A file's geohash is stable ([[map-stable-coordinates]]), so its domain is stable too; reviewers see domain changes as prefix changes in the sidecar diff ([[map-persist-coordinate-sidecar]]).

**When NOT to apply:**
- Tiny codebases with a handful of obvious domains do not need a region registry — a flat list works until prefix-based ownership earns its keep.

Reference: [CodeCity — Wettel & Lanza](https://wettel.github.io/codecity.html); [Longest prefix match](https://en.wikipedia.org/wiki/Longest_prefix_match)
