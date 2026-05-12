---
title: 'Hit WCAG AA Contrast: 4.5:1 Body Text, 3:1 Large Text and UI Components'
impact: CRITICAL
impactDescription: WCAG 1.4.3 (text) + 1.4.11 (non-text); ~8% of men and 0.5% of women have color vision deficiency; low-contrast UI is the #1 cause of a11y lawsuits in US/EU
tags: acc, color-contrast, wcag-1-4-3, wcag-1-4-11, semantic-colors
---

## Hit WCAG AA Contrast: 4.5:1 Body Text, 3:1 Large Text and UI Components

Body text (< 18 pt regular or < 14 pt bold) must have a contrast ratio of at least 4.5:1 against its background. Large text and non-text UI elements (icons, focus rings, form-field borders) need at least 3:1. Use semantic CSS variables and Tailwind tokens that have been audited — never pick colors by eyeballing. Test with the [APCA contrast tool](https://www.myndex.com/APCA/) or Chrome DevTools' color picker.

**Incorrect (low contrast — gray-400 on white = 2.85:1, fails AA):**

```tsx
<p className="text-gray-400">Description text on white background</p>
<button className="text-gray-300 border-gray-200">Submit</button>
{/* Form field placeholder using text-muted-foreground/40 — likely < 3:1 */}
<input placeholder="Search…" className="placeholder:text-muted-foreground/40" />
```

**Correct (semantic tokens with audited contrast):**

```tsx
// app/globals.css — semantic tokens defined once
@theme {
  --color-foreground: oklch(0.15 0 0);          /* near-black */
  --color-muted-foreground: oklch(0.45 0 0);    /* 4.61:1 on white — passes AA */
  --color-background: oklch(1 0 0);
  --color-border: oklch(0.85 0 0);              /* 3.14:1 — passes UI AA */
  --color-destructive: oklch(0.55 0.22 25);     /* 4.5:1+ on bg, 3:1 on white text */
}

@theme dark {
  --color-foreground: oklch(0.96 0 0);
  --color-muted-foreground: oklch(0.65 0 0);
  --color-background: oklch(0.13 0 0);
  --color-border: oklch(0.28 0 0);
}

// Components reference tokens, not raw colors
<p className="text-muted-foreground">Description text</p>
<Button variant="destructive">Delete</Button>
<input className="border-border placeholder:text-muted-foreground" placeholder="Search…" />
```

**Validate with the in-skill script:**

```bash
python scripts/verify_palette.py --foreground "#737373" --background "#FFFFFF"
# → Contrast ratio: 4.61:1 — PASSES AA for body text
```

**Status colors must be color-independent too** (see [acc-color-independent](acc-color-independent.md)):

```tsx
// Error state — icon + text + token, not just red color
<div role="alert" className="flex items-center gap-2 text-destructive">
  <AlertCircle className="size-4" aria-hidden="true" />
  <span>Email is required</span>
</div>
```

**Rule:**
- Body text ≥ 4.5:1 against its background; large text (≥ 18.66 px or ≥ 24 px bold) ≥ 3:1
- UI elements (borders, focus rings, icons) ≥ 3:1 against adjacent surfaces
- Define semantic tokens in `@theme` and audit each one once; never define colors inline
- Run `scripts/verify_palette.py` on each new color pair before shipping
- Verify in both light and dark themes — many palettes pass one but fail the other

Reference: [WCAG 1.4.3 Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) · [WCAG 1.4.11 Non-text Contrast](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html)
