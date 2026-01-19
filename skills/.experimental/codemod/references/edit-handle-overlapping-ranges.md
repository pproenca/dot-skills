---
title: Handle Overlapping Edit Ranges
impact: MEDIUM-HIGH
impactDescription: prevents corrupted output from conflicting edits
tags: edit, overlap, conflicts, ranges
---

## Handle Overlapping Edit Ranges

When multiple edits target overlapping source ranges, later edits may corrupt earlier ones. Detect and resolve conflicts before committing.

**Incorrect (overlapping edits):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Find both outer and inner expressions
  const outer = root.findAll({
    rule: { pattern: "outer($INNER)" }
  });
  const inner = root.findAll({
    rule: { pattern: "inner($ARG)" }
  });

  // Both match overlapping ranges in: outer(inner(x))
  const edits = [
    ...outer.map(o => o.replace("newOuter()")),
    ...inner.map(i => i.replace("newInner()"))
  ];

  // Result is corrupted: overlapping replacements
  return root.commitEdits(edits);
};
```

**Correct (conflict detection):**

```typescript
const transform: Transform<TSX> = (root) => {
  const outer = root.findAll({
    rule: { pattern: "outer($INNER)" }
  });
  const inner = root.findAll({
    rule: { pattern: "inner($ARG)" }
  });

  // Collect edits with range info
  const outerEdits = outer.map(o => ({
    node: o,
    range: o.range(),
    edit: o.replace("newOuter()")
  }));

  const innerEdits = inner.map(i => ({
    node: i,
    range: i.range(),
    edit: i.replace("newInner()")
  }));

  // Filter out inner edits that overlap with outer
  const nonOverlapping = innerEdits.filter(inner =>
    !outerEdits.some(outer =>
      rangesOverlap(inner.range, outer.range)
    )
  );

  const finalEdits = [
    ...outerEdits.map(e => e.edit),
    ...nonOverlapping.map(e => e.edit)
  ];

  return root.commitEdits(finalEdits);
};

function rangesOverlap(a: Range, b: Range): boolean {
  return a.start < b.end && b.start < a.end;
}
```

**Strategies for overlapping edits:**
- Prefer outer/parent edits over inner/child
- Process innermost first if preserving hierarchy
- Skip conflicting edits with filter
- Transform parent to include child changes

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)
