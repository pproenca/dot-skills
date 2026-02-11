---
title: Colocate State with Components That Use It
impact: CRITICAL
impactDescription: reduces prop passing by 60%, improves component isolation
tags: state, colocation, prop-drilling, isolation
---

## Colocate State with Components That Use It

State lifted too high forces intermediate components to forward props they do not use. Every parent in the chain re-renders when the state changes, even though only the leaf component reads it. Moving state to the component that consumes it eliminates the forwarding chain and confines re-renders.

**Incorrect (state in parent, only child uses it):**

```tsx
function ProductPage() {
  // searchQuery is only used by SearchResults, but ProductPage re-renders on every keystroke
  const [searchQuery, setSearchQuery] = useState("");

  return (
    <div>
      <ProductHeader />
      <ProductCategories />
      <SearchBar query={searchQuery} onQueryChange={setSearchQuery} />
      <SearchResults query={searchQuery} />
      <ProductFooter />
    </div>
  );
}

function SearchBar({ query, onQueryChange }: { query: string; onQueryChange: (q: string) => void }) {
  return <input value={query} onChange={(e) => onQueryChange(e.target.value)} />;
}

function SearchResults({ query }: { query: string }) {
  const results = useProductSearch(query);
  return <ul>{results.map((r) => <li key={r.id}>{r.name}</li>)}</ul>;
}
```

**Correct (state colocated in the consuming subtree):**

```tsx
function ProductPage() {
  return (
    <div>
      <ProductHeader />
      <ProductCategories />
      <ProductSearch /> {/* State lives here — ProductPage never re-renders for keystrokes */}
      <ProductFooter />
    </div>
  );
}

function ProductSearch() {
  const [searchQuery, setSearchQuery] = useState("");
  const results = useProductSearch(searchQuery);

  return (
    <div>
      <input value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} />
      <ul>{results.map((r) => <li key={r.id}>{r.name}</li>)}</ul>
    </div>
  );
}
```

Reference: [Kent C. Dodds - State Colocation](https://kentcdodds.com/blog/state-colocation-will-make-your-react-app-faster)
