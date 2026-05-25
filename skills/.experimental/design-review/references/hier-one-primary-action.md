---
title: Limit each view to one primary action
tags: hier, buttons, emphasis
---

## Limit each view to one primary action

When every button uses the same solid, high-contrast style they compete, and none reads as the main action. Give one button the primary (filled) treatment and demote the rest to secondary (outline) or tertiary (ghost) so the intended next step is obvious at a glance.

```tsx
// One filled primary; the secondary action is deliberately quieter
<div className="form-actions">
  <button className="bg-indigo-600 text-white font-medium px-4 py-2 rounded-md">
    Save changes
  </button>
  <button className="text-slate-600 px-4 py-2 rounded-md hover:bg-slate-100">
    Cancel
  </button>
</div>
```

Reference: [Refactoring UI — Hierarchy](https://www.refactoringui.com/)
