---
title: Build a Font Fallback Ladder from fontDescriptor.name to Web Stack
impact: MEDIUM
impactDescription: prevents fallback-font shifts (FOUT) and platform inconsistency on missing fonts
tags: type, font-fallback, font-stack, system-fonts
---

## Build a Font Fallback Ladder from fontDescriptor.name to Web Stack

Sketch's `fontDescriptor.attributes.name` is a single font name (e.g., `"SFProText-Regular"`). Emitting just that as `font-family` causes a Flash of Unstyled Text or wrong font when the system doesn't have it — the user sees the browser's serif default for ~200ms. Build a *ladder* of fallbacks ordered from "best match" to "platform default," ending in a generic family. For Apple's SF Pro, this ladder is `BlinkMacSystemFont, -apple-system, "Segoe UI", Roboto, ...` — and is the same regardless of which SF variant Sketch references.

**Incorrect (single-font face):**

```ts
function fontFamilyCss(name: string): string {
  return `font-family: "${name}";`;
  // Linux user without SF Pro installed: browser falls back to default serif.
  // FOUT until the web font (if any) loads.
}
```

**Correct (ladder per design-system family):**

```ts
// Configurable map: known design-system font → web fallback stack.
const FONT_STACKS: Record<string, string> = {
  'SF Pro Display': '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
  'SF Pro Text':    '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
  'SF Mono':        'ui-monospace, SFMono-Regular, Menlo, Consolas, "Liberation Mono", monospace',
  'Inter':          'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
  'Roboto':         'Roboto, -apple-system, "Segoe UI", "Helvetica Neue", Arial, sans-serif',
};

function fontFamilyCss(sketchFontName: string): string {
  // Sketch names: "SFProText-Regular", "SFProDisplay-Bold", etc. Normalize.
  const family = normalizeFamily(sketchFontName);     // "SF Pro Text"
  const stack = FONT_STACKS[family];
  if (stack) return `font-family: ${stack};`;
  // Unknown font: keep the literal but add a generic fallback.
  return `font-family: "${family}", sans-serif;`;
}

function normalizeFamily(sketchName: string): string {
  // Strip weight/style suffixes; insert spaces in CamelCase.
  return sketchName
    .replace(/-(Regular|Medium|Semibold|Bold|Light|Thin|Heavy|Black|Italic).*$/i, '')
    .replace(/([a-z])([A-Z])/g, '$1 $2')
    .replace(/Pro(Text|Display)/, 'Pro $1');
}

// Weight and style become separate CSS properties:
function fontWeightCss(sketchName: string): number {
  if (/Black|Heavy/.test(sketchName)) return 900;
  if (/Bold/.test(sketchName)) return 700;
  if (/Semibold/.test(sketchName)) return 600;
  if (/Medium/.test(sketchName)) return 500;
  if (/Light/.test(sketchName)) return 300;
  if (/Thin/.test(sketchName)) return 100;
  return 400;
}
```

**Why `-apple-system` AND `BlinkMacSystemFont`:** they map to the same SF font, but `-apple-system` works on Safari ≥ 9 and `BlinkMacSystemFont` works on Chrome/Edge on macOS. Both are needed for full coverage. The order matters: `BlinkMacSystemFont` first ensures Chrome picks SF Pro instead of falling through to system defaults; reversed order works but is less robust on older Safari.

**The `ui-` generic family for monospace:** for code/mono fonts, `ui-monospace` is the modern equivalent and resolves to SF Mono on Apple, Cascadia Mono on Windows, the system mono on Linux. Listing it first gives platform-appropriate monospace without bundling fonts.

**When to bundle vs depend on system fonts:** for a public-facing site, bundle the design-system font as a web font (woff2 ≈ 30-100KB) and put it first in the stack. For internal tools, the system fallback is acceptable and saves the bytes — Apple platforms render correctly without the bundle, and other platforms get a near-equivalent grotesque (Segoe / Roboto).

Reference: [Modern Font Stacks](https://modernfontstacks.com/)
