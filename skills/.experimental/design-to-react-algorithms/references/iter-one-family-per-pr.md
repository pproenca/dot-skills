---
title: Convert One Component Family Per Iteration
impact: HIGH
impactDescription: shrinks regression blame radius from O(n) families to 1; keeps PR diffs reviewable
tags: iter, scoping, regression-gate, code-review
---

## Convert One Component Family Per Iteration

A 2,000-line PR that touches every component family is impossible to review — reviewers either rubber-stamp it or reject it, and either way you learn nothing about which change caused which visual diff. Convert one family per iteration (all Buttons, then all Inputs, then all Cards) so the snapshot diff is scoped to one surface and any regression is unambiguously caused by the one family changed.

**Incorrect (bulk conversion):**

```ts
// One big PR: convert every symbol master in the file.
const masters = collectAllSymbolMasters(doc);
for (const m of masters) {
  await emitMasterComponent(m);
}
// 2,000-line diff, 80 snapshots changed.
// One regression in Card affects 12 screens; nobody knows which commit caused it.
```

**Correct (family-scoped iteration):**

```ts
// Group masters by family using the "/" naming convention Sketch teams use.
//   "Buttons/Primary/Default", "Buttons/Primary/Pressed", "Buttons/Secondary/..."
//   "Cards/Elevated", "Cards/Flat", ...
const families = groupBy(masters, m => m.name.split('/')[0]);

// One family per PR. Each PR ratchets the baseline forward.
const family = families.get(process.env.FAMILY);  // "Buttons"
for (const master of family) {
  await emitMasterComponent(master);
}

// Snapshot gate scoped to the family:
const report = await runVisualRegression({
  scope: family.map(m => slugify(m.name)),  // only Buttons/* snapshots
  baselineDir: 'snapshots/baseline',
});
if (report.regressions.length) process.exit(1);
```

**Why family scoping:** the `Family/Variant/State` naming pattern is universal across mature design systems (Sketch's symbol-grouping convention, Figma's component property convention) — it gives you a natural shard key for PRs and CI runs without inventing one.

**When NOT to use this pattern:** the very first pass to bootstrap the design-token layer (see [[iter-freeze-design-tokens-first]]) is global by necessity — but it touches only `tokens.css`, not components.

Reference: [Sketch Symbol Organization Guide](https://www.sketch.com/docs/symbols/)
