---
title: Promote Freeform to Flex with `gap` When Sibling Gaps Are Equal Within Tolerance
impact: HIGH
impactDescription: replaces N-1 hard-coded margins with one `gap` value; O(N) → O(1) maintenance cost
tags: layout, gap-detection, freeform-promotion, flexbox
---

## Promote Freeform to Flex with `gap` When Sibling Gaps Are Equal Within Tolerance

After [[layout-infer-flex-from-axis-projection-overlap]] establishes the axis, compute the inter-child gaps; if they are equal within tolerance, the layout is `display: flex; gap: Npx`. If not, fall back to per-child margins (or back to absolute). Detecting "equal gaps" rather than emitting `margin-right: 12px` on every child except the last produces code that survives reordering, insertion, and CSS variable-driven theme tweaks.

**Algorithm:**
1. Sort children along the main axis.
2. Compute gap[i] = child[i+1].start - child[i].end for i in [0, n-2].
3. If max(gap) - min(gap) ≤ ε, emit `gap: median(gaps)px`.
4. Otherwise emit individual `margin-{axis}` per child (or fall through to absolute).

**Incorrect (per-child margins, broken on reorder):**

```css
.row { display: flex; }
.row > .chip:not(:last-child) { margin-right: 12px; }
/* If a new chip is inserted in the middle: works.
   If a chip is reordered to last: ITS margin disappears, breaking spacing.
   :not(:last-child) is fragile under conditional rendering. */
```

**Correct (gap detection + gap property):**

```ts
function detectGap(sortedChildren: Layer[], axis: 'row' | 'column', epsilon = 0.5): number | null {
  if (sortedChildren.length < 2) return 0;

  const end = (l: Layer) => axis === 'row'
    ? l.frame.x + l.frame.width
    : l.frame.y + l.frame.height;
  const start = (l: Layer) => axis === 'row' ? l.frame.x : l.frame.y;

  const gaps: number[] = [];
  for (let i = 0; i < sortedChildren.length - 1; i++) {
    gaps.push(start(sortedChildren[i + 1]) - end(sortedChildren[i]));
  }

  const minGap = Math.min(...gaps);
  const maxGap = Math.max(...gaps);
  if (maxGap - minGap > epsilon) return null;     // not uniform — caller falls back

  // Round to nearest pixel to absorb subpixel design drift.
  return Math.round((minGap + maxGap) / 2);
}

function emitFlexLayout(group: Group, axis: 'row' | 'column'): CssProps {
  const sorted = sortAlongAxis(group.layers, axis);
  const gap = detectGap(sorted, axis);
  return {
    display: 'flex',
    flexDirection: axis,
    ...(gap !== null
        ? { gap: `${gap}px` }
        : { /* caller emits per-child margins as fallback */ }),
  };
}
```

```css
.row { display: flex; gap: 12px; }
/* Reorder-safe, insertion-safe. Themeable: gap: var(--space-3); */
```

**Why median over mean:** for nearly-uniform gaps with one outlier (a misaligned designer artifact), median is more robust. With ε guarding, median and mean usually agree — they only diverge when you should have rejected the gap detection in the first place.

**Browser support note:** `gap` on flexbox is supported in all browsers since Safari 14.1 (Apr 2021); if targeting earlier, fall back to per-child margins or polyfill via `:where()`.

Reference: [MDN — gap (CSS property)](https://developer.mozilla.org/en-US/docs/Web/CSS/gap)
