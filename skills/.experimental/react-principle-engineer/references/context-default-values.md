---
title: Provide meaningful default values
impact: LOW
impactDescription: Context default values should be sensible fallbacks, not just placeholders
tags: [context, defaults, fallbacks, createContext]
---

# Provide Meaningful Default Values

The default value passed to `createContext` is used when no provider exists in the tree. It should be a working fallback, not a placeholder.

## What Default Values Do

```tsx
// Default is used when there's NO provider above in the tree
const ThemeContext = createContext('light');  // Default: 'light'

function Button() {
  const theme = useContext(ThemeContext);

  // If no <ThemeContext.Provider> exists above,
  // theme will be 'light' (the default)
}
```

## Incorrect: Placeholder Defaults

```tsx
// Problem: Defaults that will cause runtime errors
const UserContext = createContext<User>(null as any);  // Will crash
const ConfigContext = createContext<Config>({} as Config);  // Missing fields

function UserProfile() {
  const user = useContext(UserContext);
  return <div>{user.name}</div>;  // Crashes if no provider!
}
```

## Correct: Meaningful Defaults

```tsx
// Solution: Default that works without provider
const ThemeContext = createContext<Theme>('light');

function Button() {
  const theme = useContext(ThemeContext);
  // Works fine with default 'light' if no provider
  return <button className={`btn-${theme}`}>Click</button>;
}
```

## Option 1: Null with Error Checking

```tsx
// For required contexts, use null and throw if missing
const UserContext = createContext<User | null>(null);

function useUser() {
  const user = useContext(UserContext);
  if (!user) {
    throw new Error('useUser must be used within UserProvider');
  }
  return user;
}

// Now TypeScript knows user is non-null after the hook
function UserProfile() {
  const user = useUser();  // Throws if no provider
  return <div>{user.name}</div>;  // Safe, user is User not null
}
```

## Option 2: Complete Default Object

```tsx
// For configuration that has reasonable defaults
const defaultConfig: Config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
  retries: 3,
};

const ConfigContext = createContext<Config>(defaultConfig);

function ApiClient() {
  const config = useContext(ConfigContext);
  // Works with or without provider
  return fetch(config.apiUrl);
}
```

## Option 3: Throw-on-Use Pattern

```tsx
// Default that throws when actually used
const AuthContext = createContext<AuthState>({
  user: null,
  login: () => { throw new Error('AuthProvider not found'); },
  logout: () => { throw new Error('AuthProvider not found'); },
});

// Works as type, but methods throw if provider missing
// This is sometimes useful for optional providers
```

## When Defaults Matter

```tsx
// 1. Component used outside provider (testing, docs)
function Button() {
  const theme = useContext(ThemeContext);  // Uses default in Storybook
  return <button className={theme}>Click</button>;
}

// 2. Optional enhancement
const AnalyticsContext = createContext<Analytics>({
  track: () => {},  // No-op default
});
// Components work fine without analytics provider

// 3. Progressive enhancement
const FeatureFlagContext = createContext<FeatureFlags>({
  newDashboard: false,
  darkMode: false,
});
// All features off by default
```

## Key Principle

Ask: "What should happen if this context has no provider?" If it should work, provide a functional default. If it's required, use null and throw a helpful error.
