---
title: Convert Sketch kerning (pt) to letter-spacing in em, Not px
impact: MEDIUM
impactDescription: prevents kerning drift at non-design font sizes; preserves typographic intent across breakpoints
tags: type, letter-spacing, kerning, em-conversion
---

## Convert Sketch kerning (pt) to letter-spacing in em, Not px

Sketch's `kerning` attribute on an attributedString run is an absolute pt offset added between every glyph. The same letter-spacing-in-px breaks under font scaling for the same reason as line-height — emit as em via `kerning / fontSize`. Em-relative letter-spacing scales proportionally with the font, preserving the designer's intent at any rendered size. Apple's SF Pro Display in particular relies on tight tracking (-0.5 to -0.4) that must scale to remain correct.

**Incorrect (absolute px letter-spacing):**

```ts
function emitTextRun(t: TextAttr): CssProps {
  return {
    fontSize: `${t.fontSize}px`,
    letterSpacing: `${t.kerning}px`,
    // Sketch: fontSize 14, kerning -0.42. Emit: -0.42px.
    // At a 28px responsive scale, kerning stays at -0.42px → ratio is now -0.015em
    // instead of designed -0.03em. Type looks 2x more loosely tracked than intended.
  };
}
```

**Correct (em-relative):**

```ts
function emitTextRun(t: TextAttr): CssProps {
  if (!t.kerning || t.kerning === 0) {
    return { fontSize: `${t.fontSize}px` };   // no letter-spacing → omit
  }
  const em = t.kerning / t.fontSize;
  return {
    fontSize:      `${t.fontSize}px`,
    letterSpacing: `${em.toFixed(4)}em`,
    // Sketch: fontSize 14, kerning -0.42 → -0.03em.
    // At 28px: computed letter-spacing = -0.84px. At 14px: -0.42px. Correct.
  };
}
```

**Apple SF Pro typography reference values (Sketch → CSS):**

| Design context | Sketch kerning | Sketch fontSize | em | CSS |
|---|---|---|---|---|
| Large Title | 0.37 | 34 | 0.0109 | `letter-spacing: 0.0109em` |
| Title 1 | 0.36 | 28 | 0.0129 | `letter-spacing: 0.0129em` |
| Body | -0.43 | 17 | -0.0253 | `letter-spacing: -0.0253em` |
| Caption 1 | 0 | 12 | 0 | (omit) |

These come from Apple's Human Interface Guidelines and explain why iOS designs feel inconsistent when ported — Apple uses *non-zero* kerning at every type level, and the sign flips between display (positive) and body (negative). A converter that emits `letter-spacing: 0` for the common case loses all of this.

**Edge case — single-character labels:** letter-spacing has no visible effect on single characters (nothing between which to add space), so omit the property for `string.length === 1` to keep CSS small.

Reference: [Apple Human Interface Guidelines — Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
