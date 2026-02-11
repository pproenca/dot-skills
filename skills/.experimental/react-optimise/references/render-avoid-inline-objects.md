---
title: Avoid Inline Object Creation in JSX Props
impact: HIGH
impactDescription: prevents unnecessary child re-renders, improves memo effectiveness
tags: render, inline-objects, memoization, referential-equality
---

## Avoid Inline Object Creation in JSX Props

Inline objects in JSX create a new reference on every render. When passed as props to memoized children, the new reference breaks referential equality checks, causing the child to re-render even though the values haven't changed.

**Incorrect (new object reference created every render):**

```tsx
import { memo } from "react"

interface ChartConfig {
  color: string
  strokeWidth: number
  animated: boolean
}

const RevenueChart = memo(function RevenueChart({
  config,
  revenues,
}: {
  config: ChartConfig
  revenues: number[]
}) {
  return <canvas data-config={JSON.stringify(config)} />
})

function Dashboard({ revenues }: { revenues: number[] }) {
  const [selectedTab, setSelectedTab] = useState("overview")

  return (
    <div>
      <TabBar selected={selectedTab} onSelect={setSelectedTab} />
      <RevenueChart
        revenues={revenues}
        config={{ color: "#4f46e5", strokeWidth: 2, animated: true }} // new object every render
      />
    </div>
  )
}
```

**Correct (stable reference preserved across renders):**

```tsx
import { memo } from "react"

interface ChartConfig {
  color: string
  strokeWidth: number
  animated: boolean
}

const REVENUE_CHART_CONFIG: ChartConfig = {
  color: "#4f46e5",
  strokeWidth: 2,
  animated: true,
}

const RevenueChart = memo(function RevenueChart({
  config,
  revenues,
}: {
  config: ChartConfig
  revenues: number[]
}) {
  return <canvas data-config={JSON.stringify(config)} />
})

function Dashboard({ revenues }: { revenues: number[] }) {
  const [selectedTab, setSelectedTab] = useState("overview")

  return (
    <div>
      <TabBar selected={selectedTab} onSelect={setSelectedTab} />
      <RevenueChart revenues={revenues} config={REVENUE_CHART_CONFIG} />
    </div>
  )
}
```

Reference: [React — Optimizing Performance](https://react.dev/reference/react/memo#minimizing-props-changes)
