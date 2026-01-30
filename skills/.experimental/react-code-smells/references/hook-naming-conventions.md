---
title: Follow Hook Naming Conventions
impact: MEDIUM
impactDescription: enables lint rules, improves discoverability, signals React integration
tags: hook, naming, conventions, eslint, discoverability
---

## Follow Hook Naming Conventions

Hook naming conventions enable tooling and communicate intent. Follow React's conventions for consistency.

**Code Smell Indicators:**
- Functions that call hooks but don't start with `use`
- ESLint hook rules not working
- Unclear if function is a hook or utility
- Hooks with misleading names

**Incorrect (naming issues):**

```tsx
// Doesn't start with "use" - ESLint won't check hook rules
function fetchUserData(userId: string) {
  const [user, setUser] = useState(null)  // Lint won't catch issues
  useEffect(() => {
    fetch(`/api/users/${userId}`).then(r => r.json()).then(setUser)
  }, [userId])
  return user
}

// Starts with "use" but isn't a hook - confusing
function useUtils() {
  // No hooks inside - this is just a utility module
  return {
    formatDate: (d: Date) => d.toLocaleDateString(),
    capitalize: (s: string) => s.charAt(0).toUpperCase() + s.slice(1),
  }
}

// Name doesn't describe what it does
function useHook(id: string) {  // "Hook" is not descriptive
  // ... fetch user and their posts
}
```

**Correct (proper naming):**

```tsx
// Starts with "use" - ESLint can enforce hook rules
function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchUser(userId).then(setUser).finally(() => setLoading(false))
  }, [userId])

  return { user, loading }
}

// Utilities that don't use hooks don't start with "use"
const utils = {
  formatDate: (d: Date) => d.toLocaleDateString(),
  capitalize: (s: string) => s.charAt(0).toUpperCase() + s.slice(1),
}

// Descriptive name tells you what the hook does
function useUserWithPosts(userId: string) {
  const { user } = useUser(userId)
  const { posts } = usePosts(userId)
  return { user, posts }
}
```

**Naming patterns:**

| Pattern | Example | Use Case |
|---------|---------|----------|
| `use{Resource}` | `useUser`, `useProducts` | Data fetching |
| `use{Action}` | `useToggle`, `useDebounce` | Behavior |
| `use{Feature}` | `useAuth`, `useCart` | Feature state |
| `use{Noun}State` | `useFormState` | State management |
| `use{Adjective}{Noun}` | `useLocalStorage`, `usePreviousValue` | Qualified behavior |

**ESLint configuration:**

```js
// eslint.config.js
{
  plugins: ['react-hooks'],
  rules: {
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',
  },
}
```

**TypeScript signature hints:**

```tsx
// Return type hints at hook behavior
function useToggle(initial?: boolean): [boolean, () => void]
function useAsync<T>(fn: () => Promise<T>): { data: T | null; loading: boolean; error: Error | null }
function useLocalStorage<T>(key: string, initial: T): [T, (value: T) => void]

// Name + signature together are self-documenting
```

**When it's NOT a hook:**
- Pure functions without hooks inside → regular name
- Constants and static utilities → regular name
- Factory functions that return hooks → `create{Name}Hook`

```tsx
// Factory returns a hook, not a hook itself
function createResourceHook(resourceUrl: string) {
  return function useResource(id: string) {
    const [data, setData] = useState(null)
    useEffect(() => {
      fetch(`${resourceUrl}/${id}`).then(r => r.json()).then(setData)
    }, [id])
    return data
  }
}

const useUser = createResourceHook('/api/users')
const useProduct = createResourceHook('/api/products')
```

Reference: [Your First Custom Hook](https://react.dev/learn/reusing-logic-with-custom-hooks#naming-your-custom-hooks)
