---
title: Show Loading State in SearchBar
impact: MEDIUM-HIGH
impactDescription: User feedback during search, prevents duplicate searches, better perceived performance
tags: props, search, loading, async, ux
---

## Show Loading State in SearchBar

The SearchBar component's showLoading prop displays a loading indicator during async search operations, providing essential user feedback. Without loading indication, users don't know if their search is being processed, leading to duplicate submissions and poor perceived performance. The built-in loading state integrates with the SearchBar's design without additional layout code.

**Incorrect (no loading indication during search):**

```tsx
// Bad: No feedback during async search
const SearchScreen = () => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);

  const handleSearch = async (text) => {
    setQuery(text);
    const data = await searchAPI(text);
    setResults(data);
    // User has no idea search is happening
  };

  return (
    <View>
      <SearchBar value={query} onChangeText={handleSearch} />
      <FlatList data={results} renderItem={renderItem} />
    </View>
  );
};

// Bad: Manual loading indicator outside SearchBar
const BadSearch = () => {
  const [query, setQuery] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  return (
    <View>
      <View style={styles.searchContainer}>
        <SearchBar value={query} onChangeText={setQuery} />
        {isLoading && <ActivityIndicator style={styles.loader} />}
      </View>
      {/* Inconsistent positioning, breaks SearchBar layout */}
    </View>
  );
};
```

**Correct (SearchBar showLoading prop):**

```tsx
import { SearchBar } from '@rneui/themed';

// Good: Built-in loading indicator
const SearchScreen = () => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);

  const handleSearch = async (text) => {
    setQuery(text);
    if (text.length > 2) {
      setIsSearching(true);
      const data = await searchAPI(text);
      setResults(data);
      setIsSearching(false);
    }
  };

  return (
    <View>
      <SearchBar
        value={query}
        onChangeText={handleSearch}
        showLoading={isSearching}
        placeholder="Search products..."
      />
      <FlatList data={results} renderItem={renderItem} />
    </View>
  );
};

// Good: Customize loading indicator appearance
const CustomLoadingSearch = ({ isSearching, query, onSearch }) => (
  <SearchBar
    value={query}
    onChangeText={onSearch}
    showLoading={isSearching}
    loadingProps={{
      size: 'small',
      color: '#2089dc',
    }}
    placeholder="Search..."
  />
);

// Good: Debounced search with loading state
const DebouncedSearch = () => {
  const [query, setQuery] = useState('');
  const [isSearching, setIsSearching] = useState(false);
  const [results, setResults] = useState([]);
  const debounceRef = useRef(null);

  const handleSearch = (text) => {
    setQuery(text);

    if (debounceRef.current) {
      clearTimeout(debounceRef.current);
    }

    if (text.length > 2) {
      setIsSearching(true);
      debounceRef.current = setTimeout(async () => {
        const data = await searchAPI(text);
        setResults(data);
        setIsSearching(false);
      }, 300);
    } else {
      setIsSearching(false);
      setResults([]);
    }
  };

  return (
    <View>
      <SearchBar
        value={query}
        onChangeText={handleSearch}
        showLoading={isSearching}
        platform="ios"
        placeholder="Search..."
      />
      <FlatList data={results} renderItem={renderItem} />
    </View>
  );
};

// Good: Platform-specific SearchBar with loading
const PlatformSearch = ({ query, onSearch, isLoading }) => (
  <SearchBar
    value={query}
    onChangeText={onSearch}
    showLoading={isLoading}
    platform={Platform.OS === 'ios' ? 'ios' : 'android'}
    cancelButtonTitle="Cancel"
  />
);
```

Reference: [React Native Elements SearchBar](https://reactnativeelements.com/docs/components/searchbar)
