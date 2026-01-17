---
title: Set Appropriate Line Height for Text Blocks
impact: MEDIUM-HIGH
impactDescription: improves readability by 25%+, reduces eye strain
tags: typo, line-height, readability, leading, css
---

## Set Appropriate Line Height for Text Blocks

Tight line spacing makes text hard to read and causes eye strain. Too much spacing breaks visual flow. Optimal line height depends on font size and line length.

**Incorrect (tight or inconsistent line height):**

```css
body {
  line-height: 1; /* Lines touch, hard to track */
}

p { line-height: 18px; } /* Fixed px breaks with font-size changes */

.content {
  line-height: 2.5; /* Too loose, disconnects lines */
}
/* Inconsistent line heights across the page */
```

**Correct (contextual unitless line heights):**

```css
/* Base for body text: 1.5-1.7 */
body {
  font-size: 18px;
  line-height: 1.6; /* Unitless = relative to font-size */
}

/* Tighter for large headings */
h1 {
  font-size: 48px;
  line-height: 1.1; /* Large text needs less leading */
}

h2 {
  font-size: 32px;
  line-height: 1.2;
}

/* Looser for wider measure */
.wide-content {
  max-width: 75ch;
  line-height: 1.7; /* Wider lines need more leading */
}

/* Tighter for UI elements */
.button {
  line-height: 1.2; /* UI text can be tighter */
}
```

**Line height guidelines by context:**
- Body text (40-60ch): 1.5-1.6
- Wide body text (60-80ch): 1.6-1.8
- Large headings (32px+): 1.1-1.2
- Small headings: 1.2-1.3
- UI labels/buttons: 1.1-1.3

Reference: [web.dev Line Height](https://web.dev/articles/font-size#line_height)
