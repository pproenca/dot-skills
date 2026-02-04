---
title: Use AsyncStorage for Non-Sensitive Preferences
impact: MEDIUM
impactDescription: persists user preferences across app restarts
tags: data, asyncstorage, preferences, storage
---

## Use AsyncStorage for Non-Sensitive Preferences

Use AsyncStorage for non-sensitive data like user preferences, onboarding state, or cached non-critical data.

**Incorrect (using SecureStore for preferences - overkill):**

```typescript
// SecureStore is slower and has size limits
await SecureStore.setItemAsync('theme', 'dark');
await SecureStore.setItemAsync('hasSeenOnboarding', 'true');
```

**Correct (AsyncStorage for preferences):**

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';

// Simple key-value storage
const STORAGE_KEYS = {
  THEME: '@app/theme',
  HAS_SEEN_ONBOARDING: '@app/hasSeenOnboarding',
  PREFERRED_LANGUAGE: '@app/language',
} as const;

// Store preference
async function setTheme(theme: 'light' | 'dark') {
  await AsyncStorage.setItem(STORAGE_KEYS.THEME, theme);
}

// Get preference with default
async function getTheme(): Promise<'light' | 'dark'> {
  const theme = await AsyncStorage.getItem(STORAGE_KEYS.THEME);
  return (theme as 'light' | 'dark') || 'light';
}

// Store complex object (must serialize)
async function saveUserPreferences(prefs: UserPreferences) {
  await AsyncStorage.setItem('@app/preferences', JSON.stringify(prefs));
}

// Get complex object
async function getUserPreferences(): Promise<UserPreferences | null> {
  const json = await AsyncStorage.getItem('@app/preferences');
  return json ? JSON.parse(json) : null;
}

// Usage in hook
export function useTheme() {
  const [theme, setThemeState] = useState<'light' | 'dark'>('light');

  useEffect(() => {
    getTheme().then(setThemeState);
  }, []);

  const toggleTheme = async () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    await setTheme(newTheme);
    setThemeState(newTheme);
  };

  return { theme, toggleTheme };
}
```

**Note:** Use `@` prefix for keys to namespace and avoid conflicts.

Reference: [AsyncStorage - Expo Documentation](https://docs.expo.dev/versions/latest/sdk/async-storage/)
