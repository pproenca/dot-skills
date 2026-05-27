---
title: Make values louder than their labels
tags: hier, emphasis, forms
---

## Make values louder than their labels

Detail views and forms often render the label ("Email", "Status") with the same or greater emphasis than the actual content, so the eye lands on boilerplate instead of information. Quiet the label and let the value carry the weight.

```tsx
// The label recedes; the value is the emphasised element
<div className="detail-row">
  <dt className="text-xs uppercase tracking-wide text-slate-400">Status</dt>
  <dd className="text-base font-semibold text-slate-900">Active</dd>
</div>
```

Reference: [Refactoring UI — Hierarchy](https://www.refactoringui.com/)
