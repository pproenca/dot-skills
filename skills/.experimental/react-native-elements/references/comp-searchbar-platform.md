---
title: Use Platform-Specific SearchBar Variants
impact: HIGH
impactDescription: matches platform design guidelines with zero custom styling code
tags: comp, search, platform, ux
---

## Use Platform-Specific SearchBar Variants

SearchBar supports platform-specific styling that matches iOS and Android design guidelines. Using the generic default ignores platform conventions, making your app feel foreign to users. The platform prop automatically applies native styling, animations, and behaviors.

**Incorrect (generic SearchBar ignoring platform):**

```tsx
// Bad: Generic styling doesn't match platform conventions
const Search = () => {
  const [search, setSearch] = useState('');

  return (
    <SearchBar
      placeholder="Search..."
      value={search}
      onChangeText={setSearch}
      // No platform prop - uses default styling
    />
  );
};

// Bad: Manually styling to look like platform
const ManualPlatformSearch = () => {
  const [search, setSearch] = useState('');

  return (
    <SearchBar
      placeholder="Search..."
      value={search}
      onChangeText={setSearch}
      containerStyle={{
        backgroundColor: Platform.OS === 'ios' ? '#f0f0f0' : '#fff',
        borderTopWidth: Platform.OS === 'ios' ? 0 : 1,
        // Lots of manual platform checks...
      }}
    />
  );
};
```

**Correct (platform-specific variants):**

```tsx
import { SearchBar } from '@rneui/themed';
import { Platform } from 'react-native';

// Good: Automatic platform-native styling
const PlatformSearch = () => {
  const [search, setSearch] = useState('');

  return (
    <SearchBar
      platform={Platform.OS === 'ios' ? 'ios' : 'android'}
      placeholder="Search..."
      value={search}
      onChangeText={setSearch}
      // iOS: Rounded corners, gray background, cancel button animation
      // Android: Material design, elevation, underline focus
    />
  );
};

// iOS-specific features
const IOSSearch = () => {
  const [search, setSearch] = useState('');

  return (
    <SearchBar
      platform="ios"
      placeholder="Search..."
      value={search}
      onChangeText={setSearch}
      cancelButtonTitle="Cancel"
      showCancel={search.length > 0}
      onCancel={() => setSearch('')}
    />
  );
};

// Android-specific features
const AndroidSearch = () => {
  const [search, setSearch] = useState('');

  return (
    <SearchBar
      platform="android"
      placeholder="Search..."
      value={search}
      onChangeText={setSearch}
      searchIcon={{ size: 24 }}
      clearIcon={{ size: 24 }}
      // Material Design styling applied automatically
    />
  );
};

// With loading state
const SearchWithLoading = ({ isSearching }) => {
  const [search, setSearch] = useState('');

  return (
    <SearchBar
      platform={Platform.OS === 'ios' ? 'ios' : 'android'}
      placeholder="Search..."
      value={search}
      onChangeText={setSearch}
      showLoading={isSearching}
    />
  );
};
```

Reference: [React Native Elements SearchBar](https://reactnativeelements.com/docs/components/searchbar)
