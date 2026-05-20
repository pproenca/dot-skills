---
title: Animate Dependency Load with a Bio-Inspired Flow Field
impact: MEDIUM
impactDescription: prevents static edges hiding direction and volume
tags: bio, flow-field, physarum, boids, particles
---

## Animate Dependency Load with a Bio-Inspired Flow Field

A static edge shows that A depends on B but not which way data flows or how much. Animating particles along the bundled edges — using a flux model like Physarum's tube-thickening (tubes carrying more flux grow) or boids-style steering — encodes direction as motion and volume as particle density, so heavy paths visibly pulse while idle ones stay quiet. This is decoration unless the motion carries data: gate it behind a real metric, respect reduced motion ([[access-honor-prefers-reduced-motion]]), and do not let it become chartjunk ([[encode-maximize-data-ink-drop-chartjunk]]).

**Incorrect (constant particle stream on every edge):**

```typescript
edges.forEach((e) => emitParticles(e.path, FIXED_RATE)); // pure decoration; motion encodes nothing
```

**Correct (emission rate encodes measured load; off for reduced-motion users):**

```typescript
if (matchMedia("(prefers-reduced-motion: reduce)").matches) drawWidthByLoad(edges);
else edges.forEach((e) => emitParticles(e.path, e.callsPerMin * FLOW_GAIN)); // motion = data
```

**When NOT to apply:**
- If you cannot tie particle motion to a real measured quantity, draw edge thickness or colour instead ([[bio-edge-bundling-for-dependency-overlays]]) — motion with no data behind it is the definition of chartjunk.

Reference: [Tero et al. — Rules for Biologically Inspired Adaptive Network Design (Science 2010)](https://www.science.org/doi/10.1126/science.1177894); [Reynolds — Boids (flocking model)](https://www.red3d.com/cwr/boids/)
