---
title: Use useTransition for Non-Blocking State Updates
impact: MEDIUM-HIGH
impactDescription: prevents UI freezing during expensive updates
tags: state, useTransition, concurrent, async
---

## Use useTransition for Non-Blocking State Updates

The `useTransition` hook marks state updates as non-urgent, allowing React to interrupt them for higher-priority work. This prevents the UI from freezing during expensive operations.

**Incorrect (tab switch freezes UI):**

```tsx
function Dashboard() {
  const [tab, setTab] = useState('overview')

  const handleTabChange = (newTab: string) => {
    setTab(newTab)  // If PostsTab is slow, UI freezes
  }

  return (
    <div>
      <TabList>
        <Tab onClick={() => handleTabChange('overview')}>Overview</Tab>
        <Tab onClick={() => handleTabChange('posts')}>Posts</Tab>
        <Tab onClick={() => handleTabChange('analytics')}>Analytics</Tab>
      </TabList>

      {tab === 'overview' && <OverviewTab />}
      {tab === 'posts' && <PostsTab />}  {/* Slow component */}
      {tab === 'analytics' && <AnalyticsTab />}
    </div>
  )
}
```

**Correct (tab switch stays responsive):**

```tsx
function Dashboard() {
  const [tab, setTab] = useState('overview')
  const [isPending, startTransition] = useTransition()

  const handleTabChange = (newTab: string) => {
    startTransition(() => {
      setTab(newTab)  // Low priority, can be interrupted
    })
  }

  return (
    <div>
      <TabList>
        <Tab
          onClick={() => handleTabChange('overview')}
          className={tab === 'overview' && isPending ? 'loading' : ''}
        >
          Overview
        </Tab>
        <Tab onClick={() => handleTabChange('posts')}>Posts</Tab>
        <Tab onClick={() => handleTabChange('analytics')}>Analytics</Tab>
      </TabList>

      <div style={{ opacity: isPending ? 0.7 : 1 }}>
        {tab === 'overview' && <OverviewTab />}
        {tab === 'posts' && <PostsTab />}
        {tab === 'analytics' && <AnalyticsTab />}
      </div>
    </div>
  )
}
```

**With async actions:**

```tsx
const [isPending, startTransition] = useTransition()

const handleSubmit = () => {
  startTransition(async () => {
    await saveData(formData)
    // State updates after await need another startTransition
  })
}
```

Reference: [useTransition](https://react.dev/reference/react/useTransition)
