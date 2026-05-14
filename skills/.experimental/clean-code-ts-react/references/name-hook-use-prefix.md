---
title: Hooks Are useX Verb Phrases
impact: CRITICAL
impactDescription: prevents hook-rule lint bypass at hook call sites
tags: name, hook, use-prefix, rules-of-hooks
---

## Hooks Are useX Verb Phrases

The `use` prefix is not a stylistic choice — it is the only signal React's tooling (the `react-hooks` ESLint plugin, the React compiler) has to identify a hook call site. Without the prefix, conditional or looped hook calls slip through the linter and corrupt the hooks array on re-render, producing some of the most baffling bugs in React. The verb form also tells the reader "this is stateful machinery," distinguishing it from a pure helper.

**Incorrect (no `use` prefix — linter cannot enforce Rules of Hooks):**

```tsx
// Looks like a data accessor; actually calls useState and useEffect internally.
// ESLint cannot detect when this is called conditionally.
function getCurrentUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);
  return user;
}

// Caller can break Rules of Hooks without any warning:
function ProfilePage({ userId, isVisible }: { userId: string; isVisible: boolean }) {
  if (isVisible) {
    const user = getCurrentUser(userId); // conditional hook call, silently allowed
    return <Profile user={user} />;
  }
  return null;
}
```

**Correct (`use` prefix — tooling and readers immediately know the contract):**

```tsx
// Name signals "stateful, follows Rules of Hooks".
function useCurrentUser(userId: string): User | null {
  const [user, setUser] = useState<User | null>(null);
  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);
  return user;
}

// ESLint flags the conditional call below as an error.
function ProfilePage({ userId, isVisible }: { userId: string; isVisible: boolean }) {
  const user = useCurrentUser(userId); // unconditional, top-level
  if (!isVisible || !user) return null;
  return <Profile user={user} />;
}
```

**When NOT to apply this pattern:**
- Pure helpers that happen to be called from components but do not themselves call hooks — they are functions, not hooks. `formatCurrency(amount)` should never become `useFormatCurrency`.
- Selectors in external state libraries (Zustand's `useStore(selector)`, Redux's `useSelector`) define their own conventions; you call the library hook, but your selector function does not need `use`.
- Server-only code paths (React Server Components, route handlers) where hooks are not even legal — naming a server utility `useX` would actively mislead.

**Why this matters:** A naming convention that doubles as a static enforcement mechanism is one of the highest-leverage rules in React; breaking it disables the safety net for an entire codebase.

Reference: [react.dev: Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks), [Rules of Hooks](https://react.dev/reference/rules/rules-of-hooks)
