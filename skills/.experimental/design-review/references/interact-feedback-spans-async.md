---
title: Fill the gap while an interaction is in flight
tags: interact, feedback, async
---

## Fill the gap while an interaction is in flight

This is about *time*, not styling: a control that triggers async work but sits idle for hundreds of milliseconds reads as broken, so the user clicks again and double-submits. Acknowledge within ~100ms — set a pending state on the control and disable it, or apply an optimistic update and reconcile when the request settles — so the interaction feels continuous rather than fired-into-the-void. (For how each resting/disabled state should *look*, see `state-design-all-states`.)

```tsx
const [pending, setPending] = useState(false);

async function onSubmit() {
  setPending(true);                      // instant acknowledgement, before the await
  try { await saveProfile(form); }
  finally { setPending(false); }
}

<button onClick={onSubmit} disabled={pending}>
  {pending ? 'Saving…' : 'Save'}
</button>
```

Reference: [NN/g — Response Times: The 3 Important Limits](https://www.nngroup.com/articles/response-times-3-important-limits/)
