---
title: Use Whitespace to Improve Readability
impact: HIGH
impactDescription: reduces cognitive load by 20%, improves comprehension
tags: layout, whitespace, spacing, readability, ux
---

## Use Whitespace to Improve Readability

Whitespace (negative space) reduces cognitive load and groups related content. Cramped layouts overwhelm users and hide important elements.

**Incorrect (cramped layout with no breathing room):**

```css
.card {
  padding: 8px;
  margin: 4px;
}

.card-title { margin-bottom: 2px; }
.card-description { margin-bottom: 4px; }
.card-actions { margin-top: 4px; }

.section { padding: 10px 0; }
.section-title { margin-bottom: 8px; }
/* Content feels cluttered and hard to scan */
/* No visual separation between elements */
```

**Correct (generous whitespace creates breathing room):**

```css
.card {
  padding: 24px;
  margin: 16px;
}

.card-title {
  margin-bottom: 12px;
}

.card-description {
  margin-bottom: 20px;
  line-height: 1.6;
}

.card-actions {
  margin-top: 24px;
  padding-top: 16px;
  border-top: 1px solid #eee;
}

.section {
  padding: 64px 0;
}

.section-title {
  margin-bottom: 32px;
}
/* Content has room to breathe */
/* Related elements grouped, sections clearly separated */
```

**Whitespace principles:**
- Use consistent spacing scale (8px base: 8, 16, 24, 32, 48, 64)
- More whitespace around important elements draws attention
- Group related items with less space; separate sections with more
- Line height 1.5-1.7 for body text readability

Reference: [Smashing Magazine Whitespace](https://www.smashingmagazine.com/2014/05/design-principles-space-figure-ground-relationship/)
