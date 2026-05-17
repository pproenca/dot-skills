---
title: Extract Design Tokens Before Any Component Conversion
impact: CRITICAL
impactDescription: prevents 200+ hardcoded color literals scattered across components
tags: iter, design-tokens, css-variables, dependency-order
---

## Extract Design Tokens Before Any Component Conversion

Sketch's `sharedSwatches`, `layerStyles`, and `layerTextStyles` are the design system — they are referenced by name from every layer that uses them. Convert them first into CSS custom properties (`--color-blue-8`, `--shadow-card`, `--text-body`) so component conversion can emit `var(--color-blue-8)` instead of `rgb(0 136 255)`. Reverse this order and you spend weeks de-duplicating literal colors after every theme tweak.

**Incorrect (tokens deferred or inlined):**

```ts
for (const layer of walk(page)) {
  const fill = layer.style?.fills?.[0]?.color;
  if (fill) {
    // Emit literal — token name is lost.
    emit(`color: rgb(${fill.red*255} ${fill.green*255} ${fill.blue*255});`);
  }
}
// Three months later, "change accent blue" means 200+ file edits and a manual
// audit because rgb(0 136 255) appeared in 80 places that are NOT the accent.
```

**Correct (tokens extracted first, referenced by name):**

```ts
// Phase 1: tokens. Walk doc.sharedSwatches and emit a single CSS file.
const tokens = doc.sharedSwatches.objects.map(s => ({
  cssName: `--${slugify(s.name)}`,           // "Accents/Light/8 Blue" → --accents-light-8-blue
  value: srgbToCss(s.value),                  // see style-srgb-float-to-hex-via-gamma-correct-path
}));
await writeFile('src/tokens.css', tokens.map(t => `  ${t.cssName}: ${t.value};`).join('\n'));

// Build a swatch-id → CSS-var lookup so component conversion can reference by name.
const swatchToVar = new Map(
  doc.sharedSwatches.objects.map((s, i) => [s.do_objectID, tokens[i].cssName])
);

// Phase 2: components. Resolve every color reference to a var().
function emitColor(color: SketchColor): string {
  if (color.swatchID && swatchToVar.has(color.swatchID)) {
    return `var(${swatchToVar.get(color.swatchID)})`;   // referenced token
  }
  return srgbToCss(color);                              // one-off literal — flag for review
}
```

**Why this is one-way:** once components are emitted with literals, the swatch ID is gone. Extracting tokens later requires re-parsing the .sketch file and a global codemod. Doing it first costs one extra pass and unlocks every future theme change.

Reference: [W3C CSS Custom Properties for Cascading Variables](https://www.w3.org/TR/css-variables-1/)
