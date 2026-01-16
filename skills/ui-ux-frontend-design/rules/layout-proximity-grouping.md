---
title: Group Related Elements with Proximity
impact: HIGH
impactDescription: reduces cognitive load, clarifies content relationships
tags: layout, proximity, gestalt, grouping, ux
---

## Group Related Elements with Proximity

Elements close together are perceived as related (Gestalt principle). Use proximity to create logical groups and separate unrelated content.

**Incorrect (equal spacing obscures relationships):**

```css
.form-field { margin-bottom: 24px; }
.form-label { margin-bottom: 24px; }
.form-input { margin-bottom: 24px; }
.form-hint { margin-bottom: 24px; }
/* Label appears equidistant from field above and below */
/* Unclear which label belongs to which input */
```

**Correct (proximity creates clear groupings):**

```css
.form-field {
  margin-bottom: 32px; /* Space between field groups */
}

.form-label {
  margin-bottom: 8px; /* Tight to its input */
}

.form-input {
  margin-bottom: 4px; /* Very tight to hint below */
}

.form-hint {
  margin-bottom: 0; /* Part of this field group */
}

/* Visual result: */
/* [Label]      <- 8px */
/* [Input]      <- 4px */
/* [Hint text]           */
/*              <- 32px  */
/* [Label]               */
/* [Input]               */
```

**Proximity guidelines:**
- 1:3 ratio minimum between intra-group and inter-group spacing
- Labels closer to their fields than to adjacent fields
- Card content padded more from edges than between items
- Related icons/text have minimal gap (4-8px)

Reference: [Laws of UX - Proximity](https://lawsofux.com/law-of-proximity/)
