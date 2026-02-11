---
title: Use Atomic State for Independent Reactive Values
impact: MEDIUM-HIGH
impactDescription: 3-10× fewer unnecessary re-renders in complex dashboards
tags: sub, atomic, jotai, granular-updates
---

## Use Atomic State for Independent Reactive Values

A large monolithic store triggers re-renders in every subscriber when any single field changes. Atomic state splits each independent value into its own reactive unit, so components subscribe to exactly the atoms they read.

**Incorrect (single store re-renders all consumers on any field change):**

```tsx
interface DashboardState {
  sidebarCollapsed: boolean
  activeChartRange: "1d" | "7d" | "30d"
  selectedMetric: string
  alertThreshold: number
  refreshInterval: number
}

const DashboardContext = createContext<{
  state: DashboardState
  dispatch: Dispatch<DashboardAction>
}>(null!)

function MetricSelector() {
  const { state, dispatch } = useContext(DashboardContext)
  // Re-renders when sidebarCollapsed, alertThreshold, or refreshInterval change
  return (
    <select
      value={state.selectedMetric}
      onChange={(e) => dispatch({ type: "SET_METRIC", payload: e.target.value })}
    >
      <option value="revenue">Revenue</option>
      <option value="signups">Signups</option>
    </select>
  )
}

function SidebarToggle() {
  const { state, dispatch } = useContext(DashboardContext)
  // Re-renders when selectedMetric, alertThreshold, or refreshInterval change
  return (
    <button onClick={() => dispatch({ type: "TOGGLE_SIDEBAR" })}>
      {state.sidebarCollapsed ? "Expand" : "Collapse"}
    </button>
  )
}
```

**Correct (each atom triggers re-renders only in its subscribers):**

```tsx
import { atom, useAtom } from "jotai"

const sidebarCollapsedAtom = atom(false)
const activeChartRangeAtom = atom<"1d" | "7d" | "30d">("7d")
const selectedMetricAtom = atom("revenue")
const alertThresholdAtom = atom(90)
const refreshIntervalAtom = atom(30_000)

function MetricSelector() {
  const [selectedMetric, setSelectedMetric] = useAtom(selectedMetricAtom)

  return (
    <select
      value={selectedMetric}
      onChange={(e) => setSelectedMetric(e.target.value)}
    >
      <option value="revenue">Revenue</option>
      <option value="signups">Signups</option>
    </select>
  )
}

function SidebarToggle() {
  const [sidebarCollapsed, setSidebarCollapsed] = useAtom(sidebarCollapsedAtom)

  return (
    <button onClick={() => setSidebarCollapsed((prev) => !prev)}>
      {sidebarCollapsed ? "Expand" : "Collapse"}
    </button>
  )
}
```

Reference: [Jotai — Introduction](https://jotai.org/docs/introduction)
