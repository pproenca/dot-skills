---
title: Design the empty state with guidance
tags: state, empty-state, onboarding
---

## Design the empty state with guidance

When a list or dashboard has no data yet, default UI shows a blank area that looks like a bug and gives the user no next step. Design the zero-data case explicitly, with a short explanation and the action that fills it.

```tsx
// The empty state explains the situation and offers the next action
<div className="empty-state">
  <InboxIcon aria-hidden className="text-slate-300" />
  <h3 className="font-semibold text-slate-900">No invoices yet</h3>
  <p className="text-slate-500">Create your first invoice to get started.</p>
  <button className="mt-4 bg-indigo-600 text-white px-4 py-2 rounded-md">
    New invoice
  </button>
</div>
```

Reference: [Refactoring UI — Designing empty states](https://www.refactoringui.com/)
