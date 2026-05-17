---
title: Apply paragraphSpacing Between Siblings, Never After the Last
impact: MEDIUM
impactDescription: prevents 8-24px ghost space at the bottom of text blocks
tags: type, paragraph-spacing, last-child, css-pseudo-class
---

## Apply paragraphSpacing Between Siblings, Never After the Last

Sketch's `paragraphStyle.paragraphSpacing` is the gap *after* each paragraph. Emitted as `margin-bottom: Npx` on every `<p>`, it produces an unwanted N-px gap *below the last paragraph*, eating into the container's padding or pushing the next layout element away from where the design shows it. Strip the trailing spacing via `:last-child` (or use `gap` on the parent), so the spacing is purely between siblings as Sketch renders it.

**Incorrect (margin-bottom on every paragraph):**

```css
.body p { margin-bottom: 12px; }
```

```html
<div class="body">
  <p>First paragraph...</p>
  <p>Second paragraph...</p>
  <p>Last paragraph...</p>   <!-- has unwanted 12px margin below -->
</div>
<div class="next-section">...</div>   <!-- starts 12px too far down -->
```

**Correct (strip the trailing margin):**

```css
.body p { margin-bottom: 12px; }
.body p:last-child { margin-bottom: 0; }
```

```html
<div class="body">
  <p>First paragraph...</p>
  <p>Second paragraph...</p>
  <p>Last paragraph...</p>   <!-- 0 margin below -->
</div>
<div class="next-section">...</div>   <!-- starts exactly where design shows -->
```

**Better (use gap on the container):**

```css
.body {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.body p { margin: 0; }   /* override default UA margins */
```

```ts
function paragraphStyleCss(parent: TextLayer, paragraphs: Paragraph[]): CssProps {
  const spacing = paragraphs[0]?.style?.paragraphSpacing ?? 0;
  if (spacing === 0) return {};

  // Prefer gap when the parent already needs to be flex/grid.
  // Otherwise use the :last-child override.
  return {
    display: 'flex',
    flexDirection: 'column',
    gap: `${spacing}px`,
  };
  // Emit `& > p { margin: 0; }` as a separate rule to reset UA defaults.
}
```

**Why `gap` is better than `margin + :last-child`:** `:last-child` breaks when an unintended element sneaks in (e.g., a debug `<div>` or a conditional `null` that React renders as nothing but still occupies a child slot). `gap` is purely "space between" — adds nothing trailing, regardless of what the last child is.

**Per-paragraph variation:** if different paragraphs in the same block have different `paragraphSpacing` (rare but legal in Sketch), `gap` doesn't work — fall back to per-paragraph `margin-bottom` with the `:last-child` override.

**Mind paragraph-spacing-before vs paragraph-spacing-after:** Sketch's `paragraphSpacing` is "after" (space below). CSS's typographic equivalent for "between" is what you want. If a future Sketch version exposes `paragraphSpacingBefore`, apply it as `margin-top` with `:first-child { margin-top: 0 }` — symmetric trick on the other end.

Reference: [MDN — gap (Flex and Grid)](https://developer.mozilla.org/en-US/docs/Web/CSS/gap)
