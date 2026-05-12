---
title: Settings Are Autosaved on Change; Never Gated Behind a Save Button
impact: HIGH
impactDescription: Save-button settings have 15-25% abandonment rate (users navigate away without saving); autosave with toast confirmation cuts abandonment to under 5%
tags: ux, settings, autosave, optimistic, grouping
---

## Settings Are Autosaved on Change; Never Gated Behind a Save Button

Settings (preferences, profile fields, integrations) save automatically when the user changes them. Use `useOptimistic` for instant UI feedback and confirm with a discreet toast. The Save button pattern is reserved for: (1) settings that affect billing or external systems (a confirm step is warranted), (2) wizards with multi-step input, (3) settings that must be applied atomically. Group settings by user intent ("Notifications", "Privacy"), not by data type.

**Incorrect (one giant Save button at the bottom; alphabetical grouping; loss on navigate):**

```tsx
'use client'
function SettingsPage() {
  const [draft, setDraft] = useState(loadedSettings)
  const [dirty, setDirty] = useState(false)
  return (
    <form>
      <h2>A</h2><Toggle ... onChange={() => setDirty(true)} />
      <h2>B</h2><Toggle ... onChange={() => setDirty(true)} />
      ...
      <Button onClick={() => saveAll(draft)}>Save changes</Button>
      {/* If the user navigates away → all changes lost, no warning */}
    </form>
  )
}
```

**Correct (autosave on change, optimistic update, grouped by intent, scoped Server Actions):**

```tsx
// app/settings/actions.ts
'use server'
export async function updateSettingAction(key: string, value: unknown) {
  await db.userSetting.upsert({
    where: { userId_key: { userId: getUserId(), key } },
    update: { value },
    create: { userId: getUserId(), key, value },
  })
  revalidateTag('user-settings')
  return { ok: true }
}

// app/settings/notifications-section.tsx
'use client'
import { useOptimistic, useTransition } from 'react'
import { toast } from 'sonner'
import { updateSettingAction } from './actions'

export function NotificationsSection({ initial }: { initial: NotificationSettings }) {
  const [optimistic, setOptimistic] = useOptimistic(initial)
  const [, startTransition] = useTransition()

  function update<K extends keyof NotificationSettings>(key: K, value: NotificationSettings[K]) {
    startTransition(async () => {
      setOptimistic({ ...optimistic, [key]: value })
      const result = await updateSettingAction(key, value)
      if (!result.ok) toast.error("Couldn't save — we'll retry")
    })
  }

  return (
    <section aria-labelledby="notifs-heading" className="space-y-4">
      <h2 id="notifs-heading" className="text-lg font-semibold">Notifications</h2>
      <p className="text-sm text-muted-foreground">
        Decide when we should ping you. Changes save automatically.
      </p>

      <Row label="Build finished" description="Notify me when a build I started completes">
        <Switch
          checked={optimistic.buildFinished}
          onCheckedChange={(v) => update('buildFinished', v)}
        />
      </Row>
      <Row label="Mentions" description="When someone @-mentions me">
        <Switch
          checked={optimistic.mentions}
          onCheckedChange={(v) => update('mentions', v)}
        />
      </Row>
    </section>
  )
}

function Row({ label, description, children }: { label: string; description: string; children: React.ReactNode }) {
  return (
    <div className="flex items-start justify-between gap-4 py-2">
      <div>
        <p className="font-medium">{label}</p>
        <p className="text-sm text-muted-foreground">{description}</p>
      </div>
      {children}
    </div>
  )
}
```

**When a Save button IS appropriate:**

```tsx
// Multi-step wizard or billing-affecting change — collect everything, validate atomically
'use client'
function BillingPlanForm() {
  const [state, action, pending] = useActionState(changePlanAction, {})
  return (
    <form action={action} className="space-y-4">
      <fieldset>...plan options...</fieldset>
      <p className="text-sm text-muted-foreground">
        Your card will be charged the prorated difference today.
      </p>
      <Button type="submit" disabled={pending}>
        {pending ? 'Updating plan…' : 'Confirm plan change'}
      </Button>
    </form>
  )
}
```

**Rule:**
- Default: autosave on change with `useOptimistic` + toast confirmation
- Group settings by user intent ("Notifications", "Privacy", "Workspace") — never alphabetically
- Each setting has a label and a short *why-it-matters* description
- Save buttons only for: billing, multi-step wizards, atomic-apply settings
- Settings page is a Server Component; sections are Client Components scoped to their own state

Reference: [Settings UX — NN/g](https://www.nngroup.com/articles/account-management-settings/)
