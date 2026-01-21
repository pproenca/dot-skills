---
title: Lift State Only as High as Necessary
impact: MEDIUM
impactDescription: Reduces re-renders; keeps state close to where it's used
tags: state, lifting, locality, performance
---

## Lift State Only as High as Necessary

State should live in the lowest common ancestor of components that need it. Lifting state too high causes unnecessary re-renders and makes the state's purpose unclear.

**Incorrect (state lifted too high):**

```typescript
// State in app root - causes full tree re-render on every keystroke
function App() {
  const [searchQuery, setSearchQuery] = useState('');
  const [sortOrder, setSortOrder] = useState('asc');
  const [selectedTab, setSelectedTab] = useState('all');

  return (
    <div>
      <Header />
      <Sidebar selectedTab={selectedTab} onSelectTab={setSelectedTab} />
      <ProductList
        searchQuery={searchQuery}
        onSearchChange={setSearchQuery}
        sortOrder={sortOrder}
        onSortChange={setSortOrder}
      />
      <Footer />  {/* Re-renders on every search keystroke */}
    </div>
  );
}
```

**Correct (state at lowest necessary level):**

```typescript
function App() {
  return (
    <div>
      <Header />
      <MainContent />
      <Footer />  {/* Never re-renders due to search/sort */}
    </div>
  );
}

function MainContent() {
  const [selectedTab, setSelectedTab] = useState('all');

  return (
    <>
      <Sidebar selectedTab={selectedTab} onSelectTab={setSelectedTab} />
      <ProductList selectedTab={selectedTab} />
    </>
  );
}

function ProductList({ selectedTab }: { selectedTab: string }) {
  // Search and sort state only affects ProductList subtree
  const [searchQuery, setSearchQuery] = useState('');
  const [sortOrder, setSortOrder] = useState('asc');

  return (
    <div>
      <SearchInput value={searchQuery} onChange={setSearchQuery} />
      <SortDropdown value={sortOrder} onChange={setSortOrder} />
      <ProductGrid tab={selectedTab} search={searchQuery} sort={sortOrder} />
    </div>
  );
}
```

**Decision guide:**

| Situation | Where to put state |
|-----------|-------------------|
| Single component uses it | In that component |
| Sibling components share it | In parent |
| Distant components share it | Context or store |
| Server data | Query library |

Reference: [React Docs - Sharing State](https://react.dev/learn/sharing-state-between-components)
