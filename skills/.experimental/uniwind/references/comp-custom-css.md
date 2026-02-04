---
title: Use Custom CSS Classes for Complex Reusable Styles
impact: MEDIUM-HIGH
impactDescription: reduces className verbosity for complex component styles
tags: comp, custom-css, reusable, design-system
---

## Use Custom CSS Classes for Complex Reusable Styles

Define custom CSS classes for complex, frequently used component styles. Combine them with Tailwind utilities in className.

**Incorrect (verbose repeated utility classes):**

```tsx
// Repeated across many files
<View className="flex-1 bg-card rounded-2xl shadow-lg border border-border p-6 mx-4 my-2">
  <Text className="text-lg font-semibold text-foreground mb-2">Title</Text>
  <Text className="text-sm text-muted leading-relaxed">Content</Text>
</View>
```

**Correct (custom CSS class):**

```css
/* global.css */
.card {
  flex: 1;
  background-color: var(--color-card);
  border-radius: 16px;
  border-width: 1px;
  border-color: var(--color-border);
  padding: 24px;
  margin-horizontal: 16px;
  margin-vertical: 8px;
}

.card-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--color-foreground);
  margin-bottom: 8px;
}
```

```tsx
// Clean, readable component
<View className="card shadow-lg">
  <Text className="card-title">Title</Text>
  <Text className="text-sm text-muted">Content</Text>
</View>
```

**Best practices:**
- Use flat selectors (no nesting)
- Reference theme variables for consistency
- Combine custom classes with utility overrides

Reference: [Uniwind CSS Parser](https://docs.uniwind.dev/api/css)
