---
title: Use Compound Components for Implicit State Sharing
impact: CRITICAL
impactDescription: reduces component API surface by 60%, eliminates prop drilling
tags: arch, compound-components, composition, state-sharing
---

## Use Compound Components for Implicit State Sharing

When a parent passes the same state and callbacks to N children through props, the API surface grows linearly with each new child. Compound components share state implicitly through context, keeping the public API flat and each child independently extensible.

**Incorrect (props explosion — API grows with each child):**

```tsx
interface TabsProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
  tabs: Array<{ id: string; label: string; content: React.ReactNode }>;
  renderTab?: (tab: { id: string; label: string }) => React.ReactNode;
  renderPanel?: (tab: { id: string; content: React.ReactNode }) => React.ReactNode;
  tabClassName?: string;
  panelClassName?: string;
  orientation?: "horizontal" | "vertical";
}

// 8 props and growing — every new feature adds another prop
function Tabs({ activeTab, onTabChange, tabs, renderTab, renderPanel }: TabsProps) {
  return (
    <div>
      <div role="tablist">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            role="tab"
            aria-selected={activeTab === tab.id}
            onClick={() => onTabChange(tab.id)}
          >
            {renderTab ? renderTab(tab) : tab.label}
          </button>
        ))}
      </div>
      {tabs.map((tab) => (
        <div key={tab.id} role="tabpanel" hidden={activeTab !== tab.id}>
          {renderPanel ? renderPanel(tab) : tab.content}
        </div>
      ))}
    </div>
  );
}
```

**Correct (compound pattern — implicit state via context):**

```tsx
const TabsContext = createContext<{
  activeTab: string;
  onTabChange: (tab: string) => void;
} | null>(null);

function Tabs({ children, defaultTab }: { children: React.ReactNode; defaultTab: string }) {
  const [activeTab, setActiveTab] = useState(defaultTab);
  return (
    <TabsContext.Provider value={{ activeTab, onTabChange: setActiveTab }}>
      <div>{children}</div>
    </TabsContext.Provider>
  );
}

function Tab({ id, children }: { id: string; children: React.ReactNode }) {
  const { activeTab, onTabChange } = useContext(TabsContext)!;
  return (
    <button role="tab" aria-selected={activeTab === id} onClick={() => onTabChange(id)}>
      {children}
    </button>
  );
}

function TabPanel({ id, children }: { id: string; children: React.ReactNode }) {
  const { activeTab } = useContext(TabsContext)!;
  return <div role="tabpanel" hidden={activeTab !== id}>{children}</div>;
}

// Usage — flat API, each child independently composable
<Tabs defaultTab="settings">
  <Tab id="settings">Settings</Tab>
  <Tab id="billing">Billing</Tab>
  <TabPanel id="settings"><SettingsForm /></TabPanel>
  <TabPanel id="billing"><BillingForm /></TabPanel>
</Tabs>
```

Reference: [React Docs - Passing Data Deeply with Context](https://react.dev/learn/passing-data-deeply-with-context)
