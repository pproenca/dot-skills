---
title: Use Context for Rarely-Changing Values Only
impact: CRITICAL
impactDescription: 5-50x fewer re-renders for context consumers
tags: state, context, performance, re-renders, static-values
---

## Use Context for Rarely-Changing Values Only

Every context value change re-renders the entire consumer subtree, regardless of which part of the value changed. Putting rapidly-changing data (cursor position, scroll offset, real-time counters) in context forces O(n) re-renders across all consumers on every tick. Reserve context for values that change infrequently — theme, locale, auth — and use dedicated state management for dynamic data.

**Incorrect (real-time data in context — all consumers re-render per tick):**

```tsx
interface DashboardContextValue {
  theme: "light" | "dark";
  locale: string;
  currentUser: User;
  liveVisitorCount: number;    // Updates every second
  realtimeRevenue: number;     // Updates every second
  activeAlerts: Alert[];       // Updates every few seconds
}

const DashboardContext = createContext<DashboardContextValue>(null!);

function DashboardProvider({ children }: { children: React.ReactNode }) {
  const [liveVisitorCount, setLiveVisitorCount] = useState(0);
  const [realtimeRevenue, setRealtimeRevenue] = useState(0);
  const [activeAlerts, setActiveAlerts] = useState<Alert[]>([]);

  useEffect(() => {
    // Every tick re-renders Navbar, Sidebar, Footer — everything consuming this context
    const ws = connectWebSocket("/metrics", (data) => {
      setLiveVisitorCount(data.visitors);
      setRealtimeRevenue(data.revenue);
      setActiveAlerts(data.alerts);
    });
    return () => ws.close();
  }, []);

  const value = { theme: "light", locale: "en", currentUser: user, liveVisitorCount, realtimeRevenue, activeAlerts };
  return <DashboardContext value={value}>{children}</DashboardContext>;
}
```

**Correct (context for config, dedicated state for dynamic data):**

```tsx
// Static context — changes on login or settings update only
interface AppConfigContextValue {
  theme: "light" | "dark";
  locale: string;
  currentUser: User;
}

const AppConfigContext = createContext<AppConfigContextValue>(null!);

// Real-time data stays in the components that display it
function LiveMetricsPanel() {
  const [visitorCount, setVisitorCount] = useState(0);
  const [revenue, setRevenue] = useState(0);

  useEffect(() => {
    const ws = connectWebSocket("/metrics", (data) => {
      setVisitorCount(data.visitors);
      setRevenue(data.revenue);
    });
    return () => ws.close();
  }, []);

  // Only this component re-renders per tick — not the entire app
  return (
    <div>
      <MetricCard label="Visitors" value={visitorCount} />
      <MetricCard label="Revenue" value={formatCurrency(revenue)} />
    </div>
  );
}
```

Reference: [React Docs - Scaling Up with Reducer and Context](https://react.dev/learn/scaling-up-with-reducer-and-context)
