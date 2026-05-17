---
title: Gate Every Improvement Behind a Baseline Snapshot
impact: CRITICAL
impactDescription: prevents silent regressions across the entire previously-converted surface
tags: iter, snapshot-testing, regression-gate, ci
---

## Gate Every Improvement Behind a Baseline Snapshot

The user's hard requirement — "each improvement doesn't cause regressions" — is enforceable only if every PR runs the converted React tree against a committed baseline image set and refuses to merge on regression. Without this gate, a fix to one component silently shifts the box-shadow of three others, and you discover it weeks later when the design team complains.

**Incorrect (improvements with no gate):**

```ts
// scripts/convert.ts
const result = await convertSketch('app.sketch');
await writeReact(result, 'src/generated');
// Done. Push the diff. Hope nothing else regressed.
```

**Correct (snapshot gate at the boundary):**

```ts
// scripts/convert.ts
const result = await convertSketch('app.sketch');
await writeReact(result, 'src/generated');

// Render every converted component, diff against baseline.
const report = await runVisualRegression({
  baselineDir: 'snapshots/baseline',
  componentsDir: 'src/generated',
  metric: 'ssim',           // see diff-use-ssim-for-aa-content
  regionBudgets: REGION_BUDGETS,  // see diff-region-budgeted-tolerances
});

if (report.regressions.length > 0) {
  // Surface which components regressed AND which design source changed.
  console.error('Regressions:', report.regressions);
  process.exit(1);  // CI blocks the merge.
}

// Only after green: update baselines with the new accepted state.
if (process.env.UPDATE_BASELINES === '1') {
  await report.acceptAll();
}
```

**Why a separate accept step matters:** baselines update only under explicit human intent (`UPDATE_BASELINES=1`), so an unintended change cannot silently overwrite the truth. This is the same principle as `jest --updateSnapshot` being an opt-in flag.

Reference: [Storybook Visual Regression Testing](https://storybook.js.org/docs/writing-tests/visual-testing)
