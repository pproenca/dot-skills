---
title: Use Lazy State Initialization
impact: HIGH
impactDescription: prevents expensive init on every render
tags: rerender, useState, lazy-init, initialization
---

## Use Lazy State Initialization

When initial state requires expensive computation, pass a function to `useState` instead of calling the computation directly. React only calls the initializer once, but direct calls run on every render.

**Incorrect (expensive init runs every render):**

```typescript
// screens/Dashboard.tsx
function parseStoredPreferences(): Preferences {
  const stored = localStorage.getItem('prefs');
  return stored ? JSON.parse(stored) : getDefaultPreferences();
}

export function Dashboard() {
  // parseStoredPreferences() called EVERY render, result discarded after first
  const [preferences, setPreferences] = useState(parseStoredPreferences());

  return <PreferencesPanel prefs={preferences} />;
}
```

**Correct (lazy init runs only once):**

```typescript
// screens/Dashboard.tsx
function parseStoredPreferences(): Preferences {
  const stored = localStorage.getItem('prefs');
  return stored ? JSON.parse(stored) : getDefaultPreferences();
}

export function Dashboard() {
  // Function reference passed - called only on mount
  const [preferences, setPreferences] = useState(parseStoredPreferences);

  return <PreferencesPanel prefs={preferences} />;
}
```

**Note the difference:**
- `useState(parseStoredPreferences())` - calls function, passes result
- `useState(parseStoredPreferences)` - passes function, React calls once

**Common use cases:**
- Parsing stored data (AsyncStorage, SecureStore)
- Creating initial data structures
- Complex default calculations

Reference: [useState lazy initialization](https://react.dev/reference/react/useState#avoiding-recreating-the-initial-state)
