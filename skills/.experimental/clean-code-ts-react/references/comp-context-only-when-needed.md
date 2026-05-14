---
title: Use Context for True Dependency Injection, Not Prop Avoidance
impact: MEDIUM-HIGH
impactDescription: avoids hidden coupling and re-render cascades
tags: comp, context, state, react
---

## Use Context for True Dependency Injection, Not Prop Avoidance

React Context is a dependency-injection tool for cross-cutting concerns — auth, theme, locale — that many components legitimately need. Reaching for it to skip two levels of prop passing creates hidden coupling and triggers re-render cascades on every value change. If sibling components need to share state, hoist it into their parent; reserve Context for things that actually are global.

**Incorrect (Context used for local state sharing):**

```tsx
// SelectedTab is shared between sibling panels — but they have a common parent.
// This Context now re-renders every consumer on every tab click.
const TabContext = createContext<{ selected: string; setSelected: (s: string) => void } | null>(null);

function Tabs({ children }: { children: ReactNode }) {
  const [selected, setSelected] = useState('overview');
  return (
    <TabContext value={{ selected, setSelected }}>{children}</TabContext>
  );
}

function TabPanel({ name, children }: { name: string; children: ReactNode }) {
  const ctx = useContext(TabContext)!;
  return ctx.selected === name ? <div>{children}</div> : null;
}
```

**Correct (state lives in the common parent that needs it):**

```tsx
// Tabs is the natural owner of the selected state; no Context needed.
// Re-renders are scoped to Tabs and its direct children.
function Tabs({ panels }: { panels: { name: string; content: ReactNode }[] }) {
  const [selected, setSelected] = useState(panels[0]?.name);
  return (
    <>
      <TabList names={panels.map(p => p.name)} selected={selected} onSelect={setSelected} />
      {panels.map(p =>
        p.name === selected ? <div key={p.name}>{p.content}</div> : null
      )}
    </>
  );
}
// Reserve Context for AuthContext, ThemeContext, LocaleContext — things truly global.
```

**When NOT to apply this pattern:**
- State libraries (Zustand, Jotai, Redux Toolkit) handle cross-cutting high-frequency state better than Context — when the state IS global AND updates often, reach for one of those instead of Context.
- Deep trees (5+ levels) where lifting state and threading props would create more coupling than a tightly-scoped Context.
- Compound-component patterns where Context is the implementation detail that lets `<Tabs.Panel>` find its `<Tabs>` parent — that's a legitimate, local use of Context.

**Why this matters:** Context is a dependency-injection mechanism, not a prop bypass — using it correctly preserves the same change-locality and re-render-predictability that immutability and small components give you.

Reference: [Clean Code, Chapter 10: Classes (substituted: Composition)](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [React Docs: Passing Data Deeply with Context](https://react.dev/learn/passing-data-deeply-with-context)
