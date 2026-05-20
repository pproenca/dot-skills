---
title: Encode Critical Signals Redundantly Across Channels
impact: HIGH
impactDescription: prevents total signal loss under CVD or greyscale
tags: encode, redundancy, double-encoding, accessibility, channels
---

## Encode Critical Signals Redundantly Across Channels

A signal carried on a single channel disappears whenever that channel fails — colour vanishes for color-vision-deficient users and in greyscale print, size vanishes when cells cluster, position hides under overlap. For the one or two attributes that matter most (e.g. "this module is failing CI"), encode them on two channels at once — colour *and* an outline ring — so the signal survives any single channel loss. Redundancy is cheap insurance on the marks readers can least afford to miss.

**Incorrect (failing state on colour alone):**

```typescript
getFillColor: (c) => (c.ciFailing ? RED : domainColor(c.domain)); // gone in greyscale/CVD
```

**Correct (failing state on colour and an outline):**

```typescript
new ScatterplotLayer({
  stroked: true,
  getFillColor: (c) => domainColor(c.domain),
  getLineColor: (c) => (c.ciFailing ? RED : TRANSPARENT),
  getLineWidth: (c) => (c.ciFailing ? 3 : 0),   // a thick ring also marks failure
});
```

This is the encoding-side complement of the accessibility rule ([[access-encode-redundantly-never-color-alone]]).

**When NOT to apply:**
- Do not double-encode every attribute — redundancy spent on minor channels adds clutter ([[encode-maximize-data-ink-drop-chartjunk]]). Reserve it for the few signals that must never be missed.

Reference: [WCAG 2.2 — Use of Color (1.4.1)](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html); [Munzner, Visualization Analysis & Design](https://www.cs.ubc.ca/~tmm/vadbook/)
