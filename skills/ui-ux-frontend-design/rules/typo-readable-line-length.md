---
title: Constrain Line Length for Readability
impact: MEDIUM-HIGH
impactDescription: improves reading comprehension by 20%+
tags: typo, line-length, readability, measure, ux
---

## Constrain Line Length for Readability

Lines that are too long or too short reduce reading comprehension. Optimal line length is 45-75 characters for body text. Users lose their place in overly wide text blocks.

**Incorrect (full-width text lines):**

```css
.article-content {
  width: 100%;
  padding: 0 20px;
}
/* On wide screens, lines stretch to 150+ characters */
/* Eye has to travel too far to find next line */
/* Reading comprehension drops significantly */
```

**Correct (constrained line length with ch units):**

```css
.article-content {
  max-width: 65ch; /* ~65 characters per line */
  margin: 0 auto;
  padding: 0 24px;
}

.article-content p {
  font-size: 18px;
  line-height: 1.6;
}

/* For multi-column layouts */
.two-column-layout {
  display: grid;
  grid-template-columns: minmax(auto, 65ch) 300px;
  gap: 48px;
}
/* Main content constrained, sidebar separate */
```

**Line length by context:**
- Body text: 45-75 characters (65ch ideal)
- Headings: Can be wider (up to 85ch)
- Captions/notes: Shorter (35-50ch)
- Mobile: Full width is acceptable at small viewports

**Why `ch` unit:**
- 1ch = width of the "0" character in current font
- Adapts to font-size changes automatically
- More accurate than pixel-based max-width

Reference: [Butterick Typography Line Length](https://practicaltypography.com/line-length.html)
