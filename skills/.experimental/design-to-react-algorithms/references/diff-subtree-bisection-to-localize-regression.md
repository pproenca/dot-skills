---
title: Bisect via Subtree Disable to Localize Snapshot Regressions
impact: HIGH
impactDescription: localizes regression cause in O(log n) renders vs O(n) manual inspection
tags: diff, bisection, subtree-disable, localization
---

## Bisect via Subtree Disable to Localize Snapshot Regressions

When a snapshot fails with mediocre SSIM (0.85-0.95), the culprit could be any of dozens of nested React subtrees. Replace each subtree with an inert placeholder (same bounding box, neutral fill) in a binary-search pattern; the half whose disable *restores* baseline parity contains the bug. This finds the offending node in O(log n) re-renders rather than walking the tree manually.

**Incorrect (manual inspection):**

```text
Snapshot of <Screen> failed.
Open baseline.png and actual.png side-by-side.
Squint. Toggle layers in the design file. Read 600 lines of JSX.
Eventually find: <PromoCard> shadow stack is wrong.
```

**Correct (automated subtree-disable bisection):**

```tsx
// 1. Identify the failing snapshot's React subtree root.
// 2. Render with progressively disabled subtrees and re-snapshot.

interface DisablePlan { subtreesToReplace: string[] }   // by element ID

function renderWithDisabled(plan: DisablePlan, tree: ReactElement) {
  return cloneTree(tree, (node) => {
    if (plan.subtreesToReplace.includes(node.props['data-bisect-id'])) {
      // Replace with same-bounds placeholder.
      return <div style={{ width: node.bounds.w, height: node.bounds.h, background: '#0000FF80' }} />;
    }
    return node;
  });
}

async function bisectSubtree(rootId: string, baseline: Buffer): Promise<string> {
  let candidates = collectDescendantIds(rootId);

  while (candidates.length > 1) {
    const mid = candidates.length >> 1;
    const firstHalf = candidates.slice(0, mid);
    // Disable the FIRST half. If actual now matches baseline, the bug WAS in firstHalf
    // (because disabling it removed the difference) — recurse on firstHalf.
    const actual = await render(renderWithDisabled({ subtreesToReplace: firstHalf }, tree));

    if (await matchesBaseline(actual, baseline)) {
      // Disabling firstHalf cured the diff → culprit is in firstHalf.
      candidates = firstHalf;
    } else {
      // Disabling firstHalf left the diff intact → culprit is in the OTHER half.
      candidates = candidates.slice(mid);
    }
  }
  return candidates[0];   // the singular offending node
}
```

**Why this works:** the test "does disabling subtree S restore parity" is monotonic — if S contains the bug, every superset of S also restores parity, and every subset that excludes the bug-bearing node does not. That's exactly the precondition for binary search.

**Placeholder shape matters:** the replacement must occupy the same bounding box, or the layout shifts and *that* becomes a new diff. Use a same-size `<div>` with a distinctive fill (so you can visually verify the placeholder is correct if needed).

**Combine with pHash triage:** run [[diff-perceptual-hash-for-wrong-component-detection]] first. If the bucket is `wrong-component`, bisect; if it's `aa-jitter`, don't bother — bisection burns N renders to find that the answer is "no real bug."

**Cost:** N renders for log2(N) bisection steps, where each render is one Storybook/playwright snapshot. For N=64 components, that's 6 renders — usually under 30 seconds. The alternative is a human reading 600 lines of JSX.

Reference: [git-bisect — Binary Search for Bug Introduction](https://git-scm.com/docs/git-bisect)
