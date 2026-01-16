---
title: Pass Children as Props to Avoid Re-renders
impact: MEDIUM
impactDescription: prevents re-renders of static children on parent state changes
tags: render, children, composition, optimization
---

## Pass Children as Props to Avoid Re-renders

When a component manages state, its entire subtree re-renders on state change. Passing children as props keeps static content outside the re-render boundary.

**Incorrect (static content re-renders):**

```tsx
function ExpandableSection({ title }: { title: string }) {
  const [isExpanded, setIsExpanded] = useState(false)

  return (
    <div>
      <button onClick={() => setIsExpanded(!isExpanded)}>{title}</button>
      {isExpanded && (
        <div>
          <ExpensiveContent />  {/* Re-created on every toggle */}
          <StaticFooter />
        </div>
      )}
    </div>
  )
}
```

**Correct (children stay outside state scope):**

```tsx
function ExpandableSection({
  title,
  children
}: {
  title: string
  children: React.ReactNode
}) {
  const [isExpanded, setIsExpanded] = useState(false)

  return (
    <div>
      <button onClick={() => setIsExpanded(!isExpanded)}>{title}</button>
      {isExpanded && children}  {/* Children don't re-render on toggle */}
    </div>
  )
}

// Usage
function Page() {
  return (
    <ExpandableSection title="Details">
      <ExpensiveContent />  {/* Created once in parent scope */}
      <StaticFooter />
    </ExpandableSection>
  )
}
```

**Alternative pattern (render props):**

```tsx
function ExpandableSection({
  title,
  renderContent
}: {
  title: string
  renderContent: () => React.ReactNode
}) {
  const [isExpanded, setIsExpanded] = useState(false)

  return (
    <div>
      <button onClick={() => setIsExpanded(!isExpanded)}>{title}</button>
      {isExpanded && renderContent()}
    </div>
  )
}
```

Reference: [Extracting State Logic](https://react.dev/learn/extracting-state-logic-into-a-reducer)
