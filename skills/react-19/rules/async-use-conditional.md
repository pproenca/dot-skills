---
title: Use the use Hook Conditionally
impact: HIGH
impactDescription: avoids unnecessary suspense and data fetching
tags: async, use, conditional, optimization
---

## Use the use Hook Conditionally

Unlike other hooks, `use` can be called inside conditionals and loops. This allows you to skip data fetching when it's not needed, avoiding unnecessary network requests and suspense.

**Incorrect (useContext always runs, can't be conditional):**

```tsx
function FeaturePanel({ showAdvanced }: { showAdvanced: boolean }) {
  const advancedConfig = useContext(AdvancedConfigContext)  // Always reads

  return (
    <div>
      <BasicSettings />
      {showAdvanced && <AdvancedSettings config={advancedConfig} />}
    </div>
  )
}
```

**Correct (use only reads when needed):**

```tsx
function FeaturePanel({ showAdvanced }: { showAdvanced: boolean }) {
  return (
    <div>
      <BasicSettings />
      {showAdvanced && <AdvancedSettings />}
    </div>
  )
}

function AdvancedSettings() {
  const config = use(AdvancedConfigContext)  // Only reads when rendered
  return <div>{config.featureFlags.map(f => <Flag key={f.id} flag={f} />)}</div>
}
```

**With promises (skip fetch when unnecessary):**

```tsx
function UserAvatar({ userId, showDetails }: Props) {
  // Only fetch full profile if details are shown
  const user = showDetails
    ? use(fetchFullProfile(userId))
    : use(fetchBasicProfile(userId))

  return (
    <div>
      <img src={user.avatar} alt={user.name} />
      {showDetails && <span>{user.bio}</span>}
    </div>
  )
}
```

**Benefits:**
- Skip expensive operations when not needed
- Reduce unnecessary context subscriptions
- Cleaner conditional data fetching logic

Reference: [use Hook](https://react.dev/reference/react/use#reading-context-with-use)
