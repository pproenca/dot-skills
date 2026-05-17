---
title: Collapse Pass-Through Groups Before Emit
impact: CRITICAL
impactDescription: removes 30-60% of emitted <div> wrappers; restores meaningful nesting depth
tags: tree, normalization, dom-flattening, group-collapse
---

## Collapse Pass-Through Groups Before Emit

Designers nest groups for organizational reasons that have no rendering meaning — a "Group" containing a single child, or a group whose only purpose is naming. Emitting one `<div>` per Sketch group produces a 12-level-deep DOM where the meaningful elements are buried under wrappers, breaking CSS selectors, accessibility tree heuristics, and React component boundaries. Collapse pass-through groups during tree reconstruction.

A group is **pass-through** when it satisfies *all* of:
1. Has no `style` (no fill, border, shadow, blur, opacity, blend mode)
2. Has no `MSImmutableFlexGroupLayout` (it's not laying out children)
3. Has no `hasClippingMask` (it's not clipping)
4. Has exactly one child, OR its frame exactly matches the union of its children's frames (no padding)

**Incorrect (every group becomes a div):**

```tsx
// Input: Group → Group → Group → Text
return (
  <div>           {/* Group A — just for naming */}
    <div>         {/* Group B — single-child wrapper */}
      <div>       {/* Group C — bounds match child exactly */}
        <span>Label</span>
      </div>
    </div>
  </div>
);
// CSS .label selector now needs ".container > div > div > div > span" — fragile.
```

**Correct (collapse pass-through groups during reconstruction):**

```ts
function collapsePassThrough(layer: Layer): Layer {
  const children = (layer.layers ?? []).map(collapsePassThrough);

  if (layer._class === 'group' && isPassThrough(layer, children)) {
    if (children.length === 1) {
      // Re-parent the single child to the grandparent.
      return offsetChild(children[0], layer.frame);   // preserve world coords
    }
    if (children.length === 0) return EMPTY;          // drop entirely
  }

  return { ...layer, layers: children };
}

function isPassThrough(g: Group, kids: Layer[]) {
  return !hasStyle(g.style) &&
         g.layout?._class !== 'MSImmutableFlexGroupLayout' &&
         !g.hasClippingMask &&
         (kids.length <= 1 || boundsEqualUnion(g.frame, unionFrames(kids)));
}
```

**Why preserve world coordinates:** when you re-parent a child up one level, its `x, y` was relative to the now-removed group. Add the group's frame offset to the child's frame before re-parenting, or you'll teleport the element.

**When NOT to collapse:** if the group has a `name` matching a known semantic pattern (`"Card"`, `"List Item"`, `"Section"`), preserve it as a component boundary even if it has no style — the name is the designer's intent signal.

Reference: [HTML Living Standard — The div element](https://html.spec.whatwg.org/multipage/grouping-content.html#the-div-element)
