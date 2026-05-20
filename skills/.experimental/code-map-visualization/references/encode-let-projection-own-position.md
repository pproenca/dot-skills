---
title: Let the Projection Own the Position Channel
impact: CRITICAL
impactDescription: prevents erasing coupling-as-proximity
tags: encode, position, projection, layout, stability
---

## Let the Projection Own the Position Channel

Position is the single most accurately decoded channel, and on a code map it is already spent meaningfully: the geohash projection placed coupled code near coupled code ([[map-deterministic-projection]]), so x/y *is* the domain structure. Re-deriving position with a force-directed simulation or a per-metric layout overwrites that signal — coupling-as-proximity is gone, regions scatter, and because the simulation is non-deterministic the whole map reshuffles every run, destroying the viewer's mental model and object constancy ([[anim-preserve-object-constancy-on-data-update]]). Encode additional attributes on size and colour; never by moving the cell.

**Incorrect (a second layout overwrites the projection):**

```typescript
const sim = forceSimulation(cells)                    // re-positions by degree, not domain
  .force("charge", forceManyBody())
  .force("link", forceLink(edges));
sim.tick(300);
draw(cells.map((c) => ({ ...c, xy: [c.x, c.y] })));   // projection discarded; jumps each run
```

**Correct (keep projected coordinates; vary other channels):**

```typescript
draw(cells.map((c) => ({
  xy: c.projectedXY,                                  // domain proximity preserved & stable
  radius: r(c.complexity),
  color: domainColor(c.domain),
})));
```

**When NOT to apply:**
- If you are deliberately visualising the *raw* dependency graph rather than the geohash map, a force layout is the right tool — but then you are not rendering the spatial code map this skill is about.

Reference: [Munzner, Visualization Analysis & Design](https://www.cs.ubc.ca/~tmm/vadbook/); [CodeCity — Wettel & Lanza](https://wettel.github.io/codecity.html)
