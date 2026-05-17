---
title: Hoist Shared Styles by Subtree Equivalence, Not Property Equality
impact: HIGH
impactDescription: produces 3-10x fewer CSS classes; survives single-property design tweaks
tags: tree, css-deduplication, subtree-equivalence, codegen
---

## Hoist Shared Styles by Subtree Equivalence, Not Property Equality

Naïve CSS deduplication compares per-element style objects and emits one class per unique object — but if 20 cards share the same shadow except one has `radius: 8` vs `radius: 12`, you get 20 separate classes. Hoist styles by the equivalence class of the *style subtree* (fills + borders + shadows + radii as a single fingerprint), then split only on the differing property as a modifier. This produces the CSS structure a human author would write.

**Incorrect (one class per unique style object):**

```css
/* Generated naïvely from 20 cards with one differing radius */
.card-1 { background: #fff; box-shadow: 0 1px 4px rgba(0,0,0,.1); border-radius: 12px; }
.card-2 { background: #fff; box-shadow: 0 1px 4px rgba(0,0,0,.1); border-radius: 12px; }
.card-3 { background: #fff; box-shadow: 0 1px 4px rgba(0,0,0,.1); border-radius: 8px;  }
/* ... 17 more classes, 95% identical ... */
```

**Correct (subtree equivalence + modifier classes):**

```ts
// 1. Compute style fingerprint excluding properties known to be modifier-eligible.
const MODIFIER_PROPS = new Set(['borderRadius', 'background', 'color']);

function baseFingerprint(style: Style): string {
  return sha256(JSON.stringify(omit(style, MODIFIER_PROPS)));
}

// 2. Bucket elements by base fingerprint.
const baseClasses = new Map<string, Element[]>();
for (const el of elements) {
  const fp = baseFingerprint(el.style);
  (baseClasses.get(fp) ?? baseClasses.set(fp, []).get(fp)!).push(el);
}

// 3. Emit one base class per bucket + modifier classes for each unique
//    modifier-prop value within the bucket.
for (const [fp, group] of baseClasses) {
  const baseName = inferBaseName(group);                 // "card"
  emit(`.${baseName} { ${cssFor(omit(group[0].style, MODIFIER_PROPS))} }`);

  const radiusValues = unique(group.map(el => el.style.borderRadius));
  for (const r of radiusValues) {
    emit(`.${baseName}--r${r} { border-radius: ${r}px; }`);
  }
}
```

```css
/* Resulting CSS: 1 base + 2 modifiers instead of 20 classes */
.card { background: #fff; box-shadow: 0 1px 4px rgba(0,0,0,.1); }
.card--r8  { border-radius: 8px; }
.card--r12 { border-radius: 12px; }
```

**Why modifier-eligible properties matter:** the choice of which properties are modifiers (radii, colors, padding) is the seam between "single class with overrides" and "explosion of variants." Tune this per design system — what counts as a "variant axis" vs. "base style" is system-specific.

Reference: [BEM Modifier Methodology](https://en.bem.info/methodology/quick-start/#modifier)
