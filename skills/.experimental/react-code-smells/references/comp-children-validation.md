---
title: Validate Compound Component Children
impact: MEDIUM
impactDescription: catches composition errors at development time, improves DX
tags: comp, compound-components, children, validation, developer-experience
---

## Validate Compound Component Children

Compound components that accept any children fail silently when misused. Add runtime validation to catch mistakes early.

**Code Smell Indicators:**
- Silent failures when wrong children are passed
- No error when required sub-component is missing
- Developers confused about what children are valid
- Bugs from children in wrong order

**Incorrect (silent failure on misuse):**

```tsx
function Tabs({ children }) {
  const [activeIndex, setActiveIndex] = useState(0)
  return (
    <div className="tabs">
      {React.Children.map(children, (child, index) =>
        React.cloneElement(child, {
          active: index === activeIndex,
          onClick: () => setActiveIndex(index),
        })
      )}
    </div>
  )
}

// Misuse goes undetected
<Tabs>
  <div>This isn't a Tab!</div> {/* No error, just broken */}
  <span>Neither is this</span>
</Tabs>
```

**Correct (validate children at runtime):**

```tsx
const TabContext = createContext<TabContextValue | null>(null)

function Tabs({ children, defaultIndex = 0 }) {
  const [activeIndex, setActiveIndex] = useState(defaultIndex)

  // Validate children
  const validChildren = React.Children.toArray(children).filter(child => {
    if (!React.isValidElement(child)) {
      console.warn('Tabs: Invalid child, expected Tab components')
      return false
    }
    if (child.type !== Tab && child.type !== TabList && child.type !== TabPanels) {
      console.warn(
        `Tabs: Invalid child type "${child.type}". Expected Tab, TabList, or TabPanels.`
      )
      return false
    }
    return true
  })

  if (process.env.NODE_ENV === 'development') {
    const tabList = validChildren.find(c => c.type === TabList)
    const tabPanels = validChildren.find(c => c.type === TabPanels)
    if (!tabList) console.error('Tabs: Missing required TabList child')
    if (!tabPanels) console.error('Tabs: Missing required TabPanels child')
  }

  return (
    <TabContext.Provider value={{ activeIndex, setActiveIndex }}>
      <div className="tabs">{validChildren}</div>
    </TabContext.Provider>
  )
}

function Tab({ children }) {
  const context = useContext(TabContext)
  if (!context) {
    throw new Error('Tab must be used within Tabs')
  }
  return <button role="tab">{children}</button>
}

Tabs.Tab = Tab
Tabs.TabList = TabList
Tabs.TabPanels = TabPanels
```

**TypeScript approach with explicit children types:**

```tsx
interface TabsProps {
  children: [
    React.ReactElement<TabListProps>,
    React.ReactElement<TabPanelsProps>
  ]
  defaultIndex?: number
}

// TypeScript catches wrong children at compile time
<Tabs>
  <Tabs.TabList>...</Tabs.TabList>
  <Tabs.TabPanels>...</Tabs.TabPanels>
</Tabs>
```

**displayName for better errors:**

```tsx
function Tab({ children }) { /* ... */ }
Tab.displayName = 'Tabs.Tab'

function TabList({ children }) {
  React.Children.forEach(children, child => {
    if (React.isValidElement(child) && child.type.displayName !== 'Tabs.Tab') {
      console.error(`TabList: Expected Tabs.Tab, got ${child.type.displayName || 'unknown'}`)
    }
  })
  return <div role="tablist">{children}</div>
}
```

**Benefits:**
- Errors during development, not silent production bugs
- Better developer experience
- Self-documenting valid usage
- TypeScript can catch some issues at compile time

Reference: [React Children Utilities](https://react.dev/reference/react/Children)
