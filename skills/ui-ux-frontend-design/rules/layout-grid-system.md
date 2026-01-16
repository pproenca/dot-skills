---
title: Use a Consistent Grid System
impact: HIGH
impactDescription: creates visual harmony and faster layout development
tags: layout, grid, css-grid, flexbox, consistency
---

## Use a Consistent Grid System

Grid systems create alignment and consistency across pages. Without a grid, elements feel randomly placed and layouts become difficult to maintain.

**Incorrect (arbitrary positioning and widths):**

```css
.header { padding: 15px 23px; }
.hero-section { max-width: 1150px; margin: 0 auto; }
.feature-card { width: 31.333%; margin-right: 17px; }
.sidebar { width: 287px; }
.footer { padding: 43px 20px; }
/* Arbitrary numbers everywhere */
/* No relationship between element sizes */
```

**Correct (consistent grid-based layout):**

```css
:root {
  --grid-columns: 12;
  --grid-gutter: 24px;
  --container-max: 1200px;
  --spacing-unit: 8px;
}

.container {
  max-width: var(--container-max);
  margin: 0 auto;
  padding: 0 var(--grid-gutter);
}

.grid {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: var(--grid-gutter);
}

.feature-card {
  grid-column: span 4; /* 4 of 12 columns = 1/3 width */
}

.sidebar {
  grid-column: span 3; /* 3 of 12 columns = 1/4 width */
}

.main-content {
  grid-column: span 9; /* 9 of 12 columns */
}
/* All widths derive from 12-column grid */
/* Gutters and spacing use consistent scale */
```

**Grid system benefits:**
- 12-column grid divides evenly (1, 2, 3, 4, 6, 12)
- Consistent gutters create visual rhythm
- Responsive breakpoints modify column spans
- CSS Grid makes implementation straightforward

Reference: [CSS Tricks Grid Guide](https://css-tricks.com/snippets/css/complete-guide-grid/)
