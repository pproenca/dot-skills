---
title: Onboarding Never Exceeds 3 Screens and Is Always Skippable
impact: HIGH
impactDescription: Each onboarding screen costs ~20% of users (cumulative); 4+ screen onboarding loses 50%+ of new signups (Mixpanel onboarding benchmarks)
tags: ux, onboarding, first-run, progressive-disclosure, skip
---

## Onboarding Never Exceeds 3 Screens and Is Always Skippable

Onboarding is a tax — keep it cheap. Show at most 3 screens, each communicating one concept. Provide a visible Skip on every screen (not buried in a corner). The first action after onboarding must be obvious. For optional permissions and personalization, prefer in-context prompts later — onboarding is for *understanding what the app does*, not for *collecting setup data*.

**Incorrect (5-screen forced onboarding, collects data upfront, no Skip):**

```tsx
'use client'
function ForcedOnboarding() {
  const [step, setStep] = useState(0)
  const screens = [
    <Welcome />,
    <AccountForm />,         // gathers data upfront
    <NotificationPermission />, // out of context
    <FeatureTourA />,
    <FeatureTourB />,
  ]
  return (
    <div className="fixed inset-0 bg-background p-8">
      {screens[step]}
      <Button onClick={() => setStep(step + 1)}>Next</Button>
      {/* No Skip. Required to complete to use the app. */}
    </div>
  )
}
```

**Correct (3 concise screens, always-visible Skip, defer personalization):**

```tsx
// app/(onboarding)/welcome/page.tsx
import { redirect } from 'next/navigation'
import { completeOnboardingAction } from './actions'

const SCREENS = [
  {
    title: 'Capture ideas as they happen',
    body: 'Atlas turns rough notes into structured projects you can act on.',
    image: '/onboarding/capture.svg',
  },
  {
    title: 'Collaborate without meetings',
    body: 'Invite teammates to comment, edit, and decide — async.',
    image: '/onboarding/collab.svg',
  },
  {
    title: 'Start with a template',
    body: 'Pick one to skip the blank page.',
    image: '/onboarding/templates.svg',
  },
]

export default async function Welcome({ searchParams }: { searchParams: Promise<{ step?: string }> }) {
  const { step = '0' } = await searchParams
  const i = Number(step)
  const screen = SCREENS[i]
  if (!screen) return redirect('/dashboard')

  return (
    <div className="mx-auto flex min-h-svh max-w-md flex-col items-center justify-center p-6 text-center">
      <img src={screen.image} alt="" className="size-32" />
      <h1 className="mt-6 text-2xl font-semibold">{screen.title}</h1>
      <p className="mt-2 text-muted-foreground">{screen.body}</p>

      <div className="mt-6 flex items-center gap-2" aria-label="Progress">
        {SCREENS.map((_, idx) => (
          <span
            key={idx}
            aria-current={idx === i ? 'step' : undefined}
            className={cn('size-1.5 rounded-full', idx === i ? 'bg-primary' : 'bg-muted')}
          />
        ))}
      </div>

      <div className="mt-8 flex w-full justify-between">
        <form action={completeOnboardingAction}>
          <Button variant="ghost" type="submit">Skip</Button>
        </form>
        <Button asChild>
          <Link href={`?step=${i + 1}`}>{i === SCREENS.length - 1 ? 'Get started' : 'Next'}</Link>
        </Button>
      </div>
    </div>
  )
}
```

**Rule:**
- Maximum 3 screens; each screen presents one concept (heading + 1 sentence + visual)
- Skip is visible on every screen, not hidden in a corner — text-button-ghost, bottom-left
- Don't collect data during onboarding — defer to in-context prompts (see [ux-permissions](ux-permissions.md))
- Use URL-based steps (`?step=N`) so users can back-button and refresh without losing place
- After onboarding completes, route the user to the place where the primary CTA will be — not back to a blank dashboard

Reference: [Onboarding research — NN/g](https://www.nngroup.com/articles/mobile-app-onboarding/)
