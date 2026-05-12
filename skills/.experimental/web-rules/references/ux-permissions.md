---
title: Request Browser Permissions in Context, Not on Page Load
impact: HIGH
impactDescription: Cold permission prompts (on page load) are denied at 80-90% rate; in-context prompts (after value is shown) are granted at 50-70% rate (Chrome UX research)
tags: ux, permissions, notifications, geolocation, camera, microphone
---

## Request Browser Permissions in Context, Not on Page Load

Never trigger the browser's native permission prompt as the user arrives. Show a custom "soft" prompt first — explain *why* you need the permission and *what value* the user gets — and only trigger the native prompt after they tap "Allow" in your UI. This pattern (the "double-prompt") protects the user from accidentally denying forever (browsers remember "Block" decisions but not custom prompts), and it dramatically increases grant rates.

**Incorrect (cold native prompt on page load):**

```tsx
'use client'
import { useEffect } from 'react'

function HomePage() {
  useEffect(() => {
    if ('Notification' in window && Notification.permission === 'default') {
      Notification.requestPermission() // browser modal pops the moment the page loads
    }
    navigator.geolocation.getCurrentPosition(handleLocation) // same: cold prompt
  }, [])
  return <Home />
}
```

**Correct (soft prompt → native prompt only after user opts in):**

```tsx
// components/notifications-prompt.tsx
'use client'
import { useState } from 'react'
import { Bell, X } from 'lucide-react'

export function NotificationsPrompt() {
  const [dismissed, setDismissed] = useState(false)

  if (
    dismissed ||
    typeof window === 'undefined' ||
    !('Notification' in window) ||
    Notification.permission !== 'default'
  ) {
    return null
  }

  async function onAllow() {
    const result = await Notification.requestPermission()
    if (result === 'granted') await subscribeToPush()
    setDismissed(true)
  }

  return (
    <aside
      role="dialog"
      aria-labelledby="notif-prompt-title"
      className="fixed bottom-4 right-4 max-w-sm rounded-lg border bg-background p-4 shadow-lg"
    >
      <div className="flex items-start gap-3">
        <Bell className="size-5 text-primary" aria-hidden="true" />
        <div className="flex-1">
          <h3 id="notif-prompt-title" className="font-medium">Get a ping when your build finishes</h3>
          <p className="mt-1 text-sm text-muted-foreground">
            We'll only notify you about builds you started. You can turn this off in Settings.
          </p>
          <div className="mt-3 flex gap-2">
            <Button size="sm" onClick={onAllow}>Turn on notifications</Button>
            <Button size="sm" variant="ghost" onClick={() => setDismissed(true)}>Not now</Button>
          </div>
        </div>
        <button onClick={() => setDismissed(true)} aria-label="Dismiss" className="size-8 inline-flex items-center justify-center">
          <X className="size-4" />
        </button>
      </div>
    </aside>
  )
}
```

**Trigger only when contextually valuable:**

```tsx
// Inline geolocation — only ask when the user clicks "Use my location"
function StoreLocator() {
  return (
    <div className="space-y-2">
      <input placeholder="Search by ZIP" />
      <button
        onClick={async () => {
          const pos = await new Promise<GeolocationPosition>((res, rej) =>
            navigator.geolocation.getCurrentPosition(res, rej)
          )
          setStores(await findNearby(pos.coords))
        }}
      >
        <MapPin className="mr-2 size-4" /> Use my location
      </button>
    </div>
  )
}
```

**Rule:**
- Never trigger a native permission prompt on page load or inside a `useEffect` that runs unconditionally
- Show a custom soft prompt first; trigger the native prompt only after the user taps Allow in your UI
- Explain *why* + *what the user gets* + *what data you store* — three sentences max
- "Not now" must work — store dismissal so you don't re-prompt for ≥ 7 days
- Provide an in-app Settings switch so the user can re-enable later

Reference: [Notification permission UX — Chrome team](https://web.dev/articles/push-notifications-permissions-ux)
