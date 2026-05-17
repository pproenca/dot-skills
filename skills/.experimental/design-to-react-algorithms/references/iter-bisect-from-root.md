---
title: Convert Top-Down, Bisect Bottom-Up
impact: CRITICAL
impactDescription: localizes regressions in O(log n) instead of O(n) subtree walks
tags: iter, bisection, regression-localization, workflow
---

## Convert Top-Down, Bisect Bottom-Up

Design files are deeply nested (an iOS artboard easily reaches 8-12 levels), and a layout bug at depth 3 corrupts every pixel below it. Convert the artboard from the root downward so each completed level becomes a stable reference point. When a snapshot fails, bisect *upward* from the deepest changed node — binary-disable subtrees by rendering an inert placeholder of the same bounding box — to find the highest stage that owns the regression, instead of re-reading the whole tree.

**Incorrect (leaf-first conversion, linear bisection):**

```ts
// Convert the deepest component first, then assemble parents around it.
const buttons = await convertAll(layers.filter(l => l._class === 'symbolInstance'));
const cards = await convertAll(layers.filter(l => l._class === 'group'));
const screen = await assembleScreen(cards, buttons);

// When the screen snapshot fails, walk every child to find which one broke.
for (const node of walkDepthFirst(screen)) {
  if (await snapshotDiffers(node)) console.log('broken:', node.id);  // O(n)
}
```

**Correct (top-down conversion, log-n bisection):**

```ts
// Convert the artboard root first as a placeholder shell, then refine.
const screen = await convertShell(artboard);            // 1 level deep
await commitBaseline(screen);                            // snapshot stage 0

for (const child of artboard.children) {
  const refined = await refineSubtree(screen, child);
  if (!(await passesBaseline(refined))) {
    // Bisect: disable half the subtree, re-snapshot, recurse on failing half.
    const culprit = await bisectSubtree(child, passesBaseline);  // O(log n)
    throw new RegressionAt(culprit);
  }
  await commitBaseline(refined);                         // ratchet forward
}
```

**Why bisection works:** each `commitBaseline` is a known-good checkpoint, and `passesBaseline` is a monotonic predicate over the subtree — exactly the precondition for binary search.

Reference: [Git Bisect — Binary Search Debugging](https://git-scm.com/docs/git-bisect)
