---
title: Split attributedString into Spans Only When Attributes Differ
impact: MEDIUM
impactDescription: reduces emitted text-span DOM nodes by 5-20x; preserves accessibility text nodes
tags: type, attributed-string, span-coalescing, runs
---

## Split attributedString into Spans Only When Attributes Differ

A Sketch text layer's `attributedString` stores text as a string plus an array of `attributes` (each with a range and font/color/kerning attributes). If you emit one `<span>` per attribute entry without checking, you get 60 single-character spans for a label like "Hello, world" — bloated DOM, broken text selection, broken screen readers reading character-by-character. Coalesce adjacent attributes that are identical, and only split at genuine attribute boundaries.

**Incorrect (one span per attribute entry):**

```tsx
function emitText(text: SketchText): JSX.Element {
  const str = text.attributedString.string;
  return (
    <span>
      {text.attributedString.attributes.map((attr, i) => (
        <span key={i} style={spanStyle(attr)}>
          {str.slice(attr.location, attr.location + attr.length)}
        </span>
      ))}
    </span>
  );
  // For a label with default attributes on every character:
  // attributes = [{loc:0, len:1, ...}, {loc:1, len:1, ...}, ...]
  // Result: <span><span>H</span><span>e</span><span>l</span>...</span>
}
```

**Correct (coalesce identical adjacent runs):**

```ts
type Attr = { fontName: string; fontSize: number; color: string; kerning?: number };

function coalesceRuns(
  str: string,
  attrs: { location: number; length: number; attributes: Attr }[],
): { text: string; attr: Attr }[] {
  // Sort by location; merge adjacent attrs that are deepEqual.
  const sorted = [...attrs].sort((a, b) => a.location - b.location);
  const runs: { text: string; attr: Attr }[] = [];

  for (const a of sorted) {
    const slice = str.slice(a.location, a.location + a.length);
    const prev = runs[runs.length - 1];
    if (prev && attrEqual(prev.attr, a.attributes)) {
      prev.text += slice;             // extend the existing run
    } else {
      runs.push({ text: slice, attr: a.attributes });
    }
  }
  return runs;
}

function attrEqual(a: Attr, b: Attr): boolean {
  return a.fontName === b.fontName
      && a.fontSize === b.fontSize
      && a.color === b.color
      && (a.kerning ?? 0) === (b.kerning ?? 0);
}

function emitText(text: SketchText): JSX.Element {
  const runs = coalesceRuns(text.attributedString.string, text.attributedString.attributes);

  // Single-run case: no inner span needed — apply attrs to the outer element directly.
  if (runs.length === 1) {
    return <p style={spanStyle(runs[0].attr)}>{runs[0].text}</p>;
  }
  // Multi-run: wrap each run in a span.
  return (
    <p>
      {runs.map((r, i) => <span key={i} style={spanStyle(r.attr)}>{r.text}</span>)}
    </p>
  );
}
```

**Why DOM bloat matters for diff:** every `<span>` produces a separate text node in the accessibility tree, and over-fragmented text often fails screen-reader continuity tests. It also makes hover/selection styling brittle and slows React reconciliation on long strings.

**When to keep splits at character boundaries:** if the design genuinely varies per character (gradient text painted via per-char color attrs, or a deliberate decorative effect), the coalesce step will leave them un-merged — no special case needed. Coalescing is safe because it only merges *equal* attrs.

Reference: [Apple — NSAttributedString documentation](https://developer.apple.com/documentation/foundation/nsattributedstring)
