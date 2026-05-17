---
title: Flatten Boolean Operations at Parse Time, Not Render Time
impact: MEDIUM
impactDescription: removes runtime path-boolean dependency; produces a single shippable SVG path per shapeGroup
tags: path, boolean-operations, flatten, parse-time
---

## Flatten Boolean Operations at Parse Time, Not Render Time

A Sketch `shapeGroup` with `booleanOperation` field (0=union, 1=subtract, 2=intersect, 3=difference) is a composite shape: its visual result is the boolean combination of its children's paths. Deferring this to render time means shipping a path-boolean library (paper.js, clipper-lib — 50-200KB) to the browser, plus runtime computation cost per shape. Compute the boolean *once* at parse/build time, emit a single flattened SVG path, and ship neither the library nor the children.

**Incorrect (defer boolean to client):**

```tsx
// Component bundles paper.js (140KB gzipped) and recomputes the union per render.
import { Path } from 'paper';

function ShapeGroupBoolean({ children }: { children: Path[] }) {
  const composed = children.reduce((acc, child, i) => {
    if (i === 0) return child;
    return acc.unite(child);    // or .subtract, .intersect ...
  });
  return <path d={composed.exportSVG().attr('d')} />;
  // 140KB shipped to every user, recomputed on every render.
}
```

**Correct (flatten at parse, emit one path):**

```ts
// At convert time — runs in Node, paper.js lives in devDeps only.
import paper from 'paper';

const OPS: Record<number, string> = {
  0: 'unite',
  1: 'subtract',
  2: 'intersect',
  3: 'exclude',   // "difference" in Sketch = symmetric exclude in paper
};

function flattenShapeGroup(group: ShapeGroup): string {
  // Set up paper canvas (headless).
  paper.setup(new paper.Size(group.frame.width, group.frame.height));

  const paths = group.layers.map(layer => {
    return new paper.Path({ pathData: pathToSvg(layer.points, layer.frame, true) });
  });

  const operation = OPS[group.booleanOperation ?? 0];
  let composed = paths[0];
  for (let i = 1; i < paths.length; i++) {
    // @ts-expect-error — paper's method names match the OPS map.
    composed = composed[operation](paths[i]);
  }

  const d = composed.exportSVG({ asString: true });
  paper.project.clear();
  return d;
}

// Output: <path d="M...Z" /> — one shippable string, no client dependency.
```

**The build-time vs run-time trade:**

| Concern | Client-side boolean | Pre-flattened path |
|---|---|---|
| Bundle size impact | +50-200KB | 0 |
| Render cost | per render | 0 |
| Editability | child paths preserved | flat (one-way conversion) |
| Snapshot stability | depends on paper version client-side | deterministic at build |

**When to keep children separate (rare):** if the boolean composition needs to *animate* (one child moving relative to another, with the union recomputed at each frame), pre-flattening loses that. Such cases are rare; if you have them, isolate the animated subset and pre-flatten everything else.

**Edge case — empty results:** subtract / intersect can produce an empty path. Emit `<path d="" />` and CSS `display: none` rather than a 0-length path string that crashes some SVG parsers.

Reference: [Paper.js — Path boolean operations](http://paperjs.org/reference/path/#unite-path)
