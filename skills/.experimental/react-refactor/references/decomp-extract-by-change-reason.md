---
title: Extract Components by Independent Change Reasons
impact: HIGH
impactDescription: 70% fewer files touched per feature change
tags: decomp, single-responsibility, change-isolation, extraction
---

## Extract Components by Independent Change Reasons

Code that changes for different business reasons should live in different components. When a navigation redesign forces you to touch the same file as a search algorithm change, the component has multiple change reasons that create unnecessary merge conflicts and regression risk.

**Incorrect (navigation, search, and user menu change for different reasons but live together):**

```tsx
function AppHeader() {
  const [searchQuery, setSearchQuery] = useState("");
  const [searchResults, setSearchResults] = useState<SearchResult[]>([]);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const navigation = useNavigation();
  const currentUser = useCurrentUser();

  useEffect(() => {
    const controller = new AbortController();
    if (searchQuery.length > 2) {
      searchProducts(searchQuery, controller.signal).then(setSearchResults);
    }
    return () => controller.abort();
  }, [searchQuery]);

  return (
    <header>
      <nav>
        {/* Changes when routes change */}
        {navigation.routes.map((route) => (
          <a key={route.path} href={route.path}>{route.label}</a>
        ))}
      </nav>
      <div>
        {/* Changes when search algorithm changes */}
        <input value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} />
        {searchResults.map((result) => (
          <SearchResultCard key={result.id} result={result} />
        ))}
      </div>
      <div>
        {/* Changes when auth/profile features change */}
        <button onClick={() => setIsMenuOpen(!isMenuOpen)}>
          {currentUser.avatarUrl
            ? <img src={currentUser.avatarUrl} alt={currentUser.name} />
            : <span>{currentUser.initials}</span>}
        </button>
        {isMenuOpen && <UserMenuDropdown user={currentUser} />}
      </div>
    </header>
  );
}
```

**Correct (each section extracted by its independent change reason):**

```tsx
function AppHeader() {
  return (
    <header>
      <MainNavigation />
      <ProductSearch />
      <UserMenu />
    </header>
  );
}

function MainNavigation() {
  // Changes only when routes change
  const navigation = useNavigation();

  return (
    <nav>
      {navigation.routes.map((route) => (
        <a key={route.path} href={route.path}>{route.label}</a>
      ))}
    </nav>
  );
}

function ProductSearch() {
  // Changes only when search features change
  const [searchQuery, setSearchQuery] = useState("");
  const searchResults = useProductSearch(searchQuery);

  return (
    <div>
      <input value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} />
      {searchResults.map((result) => (
        <SearchResultCard key={result.id} result={result} />
      ))}
    </div>
  );
}

function UserMenu() {
  // Changes only when auth/profile features change
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const currentUser = useCurrentUser();

  return (
    <div>
      <button onClick={() => setIsMenuOpen(!isMenuOpen)}>
        {currentUser.avatarUrl
          ? <img src={currentUser.avatarUrl} alt={currentUser.name} />
          : <span>{currentUser.initials}</span>}
      </button>
      {isMenuOpen && <UserMenuDropdown user={currentUser} />}
    </div>
  );
}
```

Reference: [Single Responsibility Principle Applied to React](https://react.dev/learn/thinking-in-react#step-1-break-the-ui-into-a-component-hierarchy)
