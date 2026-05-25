---
title: Drive wizard steps from the URL and let Activity preserve field state
tags: mutate, wizard, activity, searchparams
---

## Drive wizard steps from the URL and let Activity preserve field state

For a multi-step form/wizard the model holds the current step in `useState` and re-mounts the tree per step — so refresh/back/deep-link lose the step, and moving between steps wipes entered values. Drive the active step from the URL (`searchParams` or route segments) so it is shareable and reload-safe; keep the wizard chrome (progress bar, layout) static in the shell with only the step body behind a `<Suspense>`. With Cache Components, React `<Activity>` (applied automatically at the route level, keeping up to 3 routes mounted with `display: none`) preserves each step's in-progress field state across navigations — so don't add a global store just to retain inputs. Reset stale field/success state deliberately after a successful submit (e.g. a `useLayoutEffect` cleanup), since the preserved DOM would otherwise show it again.

```tsx
// app/onboarding/page.tsx — step lives in the URL: /onboarding?step=billing
import { Suspense } from 'react'

const STEPS = ['account', 'billing', 'review'] as const

export default async function Wizard({
  searchParams,
}: {
  searchParams: Promise<{ step?: string }>
}) {
  const { step = 'account' } = await searchParams
  return (
    <>
      <WizardProgress steps={STEPS} current={step} /> {/* static chrome in the shell */}
      <Suspense fallback={<StepSkeleton />}>
        <Step name={step} /> {/* Activity preserves fields when the user steps back */}
      </Suspense>
    </>
  )
}
```

Reference: [Preserving UI state with Activity](https://nextjs.org/docs/app/guides/preserving-ui-state)
