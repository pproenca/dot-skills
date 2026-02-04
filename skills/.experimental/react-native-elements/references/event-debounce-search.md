---
title: Debounce SearchBar onChangeText
impact: MEDIUM
impactDescription: Reduces API calls by 80-90% and eliminates input lag during typing
tags: event, debounce, SearchBar, performance, API
---

## Debounce SearchBar onChangeText

Firing API calls or expensive operations on every keystroke overwhelms both the network and the JavaScript thread. Users typing "react native" would trigger 12 separate requests without debouncing. A 300-500ms debounce delay ensures smooth typing while still feeling responsive.

**Incorrect (API call on every keystroke):**

```tsx
import { SearchBar } from '@rneui/themed';

function ProductSearch() {
  const [search, setSearch] = useState('');
  const [results, setResults] = useState([]);

  const handleSearch = (text: string) => {
    setSearch(text);
    // BAD: API call fires on every keystroke
    // Typing "shoes" = 5 API calls in rapid succession
    fetch(`/api/search?q=${text}`)
      .then((res) => res.json())
      .then(setResults);
  };

  return (
    <SearchBar
      placeholder="Search products..."
      onChangeText={handleSearch}
      value={search}
    />
  );
}
```

**Correct (debounced search with 300ms delay):**

```tsx
import { useState, useCallback, useMemo } from 'react';
import { SearchBar } from '@rneui/themed';
import debounce from 'lodash.debounce';

function ProductSearch() {
  const [search, setSearch] = useState('');
  const [results, setResults] = useState([]);

  // Memoize the debounced API call
  const debouncedSearch = useMemo(
    () =>
      debounce((text: string) => {
        if (text.length > 2) {
          fetch(`/api/search?q=${text}`)
            .then((res) => res.json())
            .then(setResults);
        }
      }, 300),
    []
  );

  // Update local state immediately, debounce API call
  const handleSearch = useCallback(
    (text: string) => {
      setSearch(text); // Immediate UI update
      debouncedSearch(text); // Debounced API call
    },
    [debouncedSearch]
  );

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      debouncedSearch.cancel();
    };
  }, [debouncedSearch]);

  return (
    <SearchBar
      placeholder="Search products..."
      onChangeText={handleSearch}
      value={search}
    />
  );
}
```

Reference: [React Native Performance](https://reactnative.dev/docs/performance)
