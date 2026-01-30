---
title: Avoid Inline Objects in JSX Props
impact: MEDIUM
impactDescription: prevents unnecessary child re-renders, improves memo effectiveness
tags: render, inline-objects, props, memoization, performance
---

## Avoid Inline Objects in JSX Props

Inline objects create new references every render, defeating memo() and causing child re-renders. Extract or memoize object props.

**Code Smell Indicators:**
- Child components re-render despite memo()
- React DevTools shows props changing when they shouldn't
- Objects created in JSX like `style={{}}` or `options={{}}`
- Performance issues in lists

**Incorrect (inline objects break memo):**

```tsx
function ParentComponent() {
  const [count, setCount] = useState(0)

  return (
    <div>
      <button onClick={() => setCount(c => c + 1)}>Count: {count}</button>

      {/* These re-render every time parent renders */}
      <MemoizedChart
        data={items}
        options={{ animate: true, showLegend: true }}  // New object every render
        style={{ width: 300, height: 200 }}  // New object every render
        callbacks={{  // New object every render
          onClick: (item) => console.log(item),
          onHover: (item) => setHovered(item),
        }}
      />

      <MemoizedList
        items={items}
        renderItem={(item) => <Item key={item.id} {...item} />}  // New function every render
      />
    </div>
  )
}
```

**Correct (stable references):**

```tsx
// Option 1: Extract to module scope (static values)
const CHART_OPTIONS = { animate: true, showLegend: true }
const CHART_STYLE = { width: 300, height: 200 }

function ParentComponent() {
  const [count, setCount] = useState(0)
  const [hovered, setHovered] = useState(null)

  // Option 2: useMemo for computed values
  const chartData = useMemo(() =>
    items.map(item => ({ x: item.date, y: item.value })),
    [items]
  )

  // Option 3: useCallback for functions
  const handleChartClick = useCallback((item) => {
    console.log(item)
  }, [])

  const handleChartHover = useCallback((item) => {
    setHovered(item)
  }, [])

  const callbacks = useMemo(() => ({
    onClick: handleChartClick,
    onHover: handleChartHover,
  }), [handleChartClick, handleChartHover])

  // Option 4: useCallback for render functions
  const renderItem = useCallback(
    (item) => <Item key={item.id} {...item} />,
    []
  )

  return (
    <div>
      <button onClick={() => setCount(c => c + 1)}>Count: {count}</button>

      <MemoizedChart
        data={chartData}
        options={CHART_OPTIONS}
        style={CHART_STYLE}
        callbacks={callbacks}
      />

      <MemoizedList
        items={items}
        renderItem={renderItem}
      />
    </div>
  )
}
```

**Pattern: Component-level constants:**

```tsx
// At module scope - created once
const defaultOptions = {
  animate: true,
  duration: 300,
}

const containerStyle = {
  display: 'flex',
  gap: '1rem',
}

function Component({ customOptions }) {
  // Merge with defaults using useMemo
  const options = useMemo(
    () => ({ ...defaultOptions, ...customOptions }),
    [customOptions]
  )

  return (
    <div style={containerStyle}>
      <Chart options={options} />
    </div>
  )
}
```

**When inline objects are OK:**

```tsx
// Component is not memoized - inline doesn't matter
function NonMemoizedChild({ style }) {
  return <div style={style}>Content</div>
}

// In a component that already re-renders on every parent render
<NonMemoizedChild style={{ color: 'red' }} />

// Style object used once, not passed to memoized child
<div style={{ padding: 10 }}>Static content</div>
```

**Audit checklist:**
```
For each inline object prop:
├── Is child memoized? → Extract or memoize
├── Is this in a list? → Definitely extract
├── Does parent re-render often? → Extract
└── Static value? → Module scope constant
```

Reference: [Optimizing Re-renders](https://react.dev/reference/react/memo#minimizing-props-changes)
