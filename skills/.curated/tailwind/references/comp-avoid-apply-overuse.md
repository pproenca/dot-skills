---
title: Avoid Overusing @apply
impact: MEDIUM-HIGH
impactDescription: prevents CSS bloat, maintains utility-first benefits
tags: comp, apply, abstraction, maintainability, css
---

## Avoid Overusing @apply

While `@apply` extracts utility patterns into custom classes, overuse defeats the purpose of utility-first CSS. Use it sparingly for small, highly reusable patterns.

**Incorrect (over-abstraction):**

```css
/* Recreating traditional CSS with extra steps */
@utility card {
  @apply bg-white rounded-lg shadow-md p-6 border border-gray-200;
}

@utility card-header {
  @apply text-xl font-bold text-gray-900 mb-4;
}

@utility card-body {
  @apply text-gray-600 leading-relaxed;
}

@utility card-footer {
  @apply mt-4 pt-4 border-t border-gray-200 flex justify-end gap-2;
}
/* Now you have to manage class names AND jump between files */
```

**Correct (utility-first with components):**

```tsx
// Card.tsx - Component handles abstraction
function Card({ children, className }) {
  return (
    <div className={`bg-white rounded-lg shadow-md p-6 border border-gray-200 ${className}`}>
      {children}
    </div>
  );
}

// Usage
<Card className="hover:shadow-lg">
  <h2 className="text-xl font-bold text-gray-900 mb-4">Title</h2>
  <p className="text-gray-600 leading-relaxed">Content</p>
</Card>
```

**When @apply is appropriate:**
- Tiny, repeated patterns (buttons, badges)
- Third-party component styling you can't control
- Base form element resets

Reference: [Tailwind CSS Reusing Styles](https://tailwindcss.com/docs/reusing-styles)
