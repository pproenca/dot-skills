---
title: Design every interactive state, not just the default
tags: state, feedback, components
---

## Design every interactive state, not just the default

Generated components usually style only the resting state, and sometimes hover, so disabled, loading, and error states look broken or unstyled when they appear. Decide up front how each interactive element looks when hovered, focused, pressed, disabled, and loading.

```tsx
// A button whose disabled and loading states are deliberately styled
<button
  disabled={isSubmitting}
  className="bg-indigo-600 text-white px-4 py-2 rounded-md
             hover:bg-indigo-700
             disabled:opacity-50 disabled:cursor-not-allowed"
>
  {isSubmitting ? 'Saving…' : 'Save changes'}
</button>
```

Reference: [Refactoring UI — Designing for states](https://www.refactoringui.com/)
