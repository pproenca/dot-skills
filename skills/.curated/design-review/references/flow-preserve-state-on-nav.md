---
title: Preserve scroll and view state across navigation
tags: flow, state, navigation
---

## Preserve scroll and view state across navigation

Client-side navigation often resets scroll to the top and drops the user's filters, sort, and search, so pressing Back lands them in a different place than they left and forces them to re-apply everything. Keep view state in the URL (search params) so it survives Back, refresh, and sharing, and let the browser restore scroll — or restore it yourself for virtualized lists where `history.scrollRestoration` can't.

```tsx
// Filters live in the URL: Back, refresh, and a shared link all restore the same view
const [params, setParams] = useSearchParams();
const status = params.get('status') ?? 'all';

function setStatus(next: string) {
  setParams(prev => { prev.set('status', next); return prev; }, { replace: true });
}
```

Reference: [MDN — History.scrollRestoration](https://developer.mozilla.org/en-US/docs/Web/API/History/scrollRestoration)
