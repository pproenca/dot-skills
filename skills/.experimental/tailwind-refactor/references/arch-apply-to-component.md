---
title: Extract @apply Blocks into Framework Components
impact: MEDIUM
impactDescription: reduces CSS bundle, improves reusability
tags: arch, apply, components, architecture
---

## Extract @apply Blocks into Framework Components

`@apply` breaks the utility-first paradigm by creating inflexible style sets locked in CSS. It increases the CSS bundle size (every `@apply` duplicates the underlying declarations), cannot accept props or conditional logic, and makes overrides painful. Component extraction gives you the reuse of `@apply` with the full flexibility of utilities and framework features.

**Incorrect (what's wrong):**

```css
/* Repeated @apply blocks for button variants */
.btn {
  @apply inline-flex items-center gap-2 rounded-lg px-4 py-2 font-medium transition-colors;
}
.btn-primary {
  @apply bg-blue-500 text-white hover:bg-blue-600;
}
.btn-secondary {
  @apply bg-gray-100 text-gray-800 hover:bg-gray-200;
}
```

**Correct (what's right):**

```tsx
// Framework component with utility classes directly in markup
function Button({ variant = 'primary', children, ...props }) {
  const styles = {
    primary: 'bg-blue-500 text-white hover:bg-blue-600',
    secondary: 'bg-gray-100 text-gray-800 hover:bg-gray-200',
  };

  return (
    <button
      className={`inline-flex items-center gap-2 rounded-lg px-4 py-2 font-medium transition-colors ${styles[variant]}`}
      {...props}
    >
      {children}
    </button>
  );
}
```
