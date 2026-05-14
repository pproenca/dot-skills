---
title: JSDoc for Public APIs and Non-Obvious Side Effects
impact: HIGH
impactDescription: surfaces intent and side effects at the call site where consumers actually look
tags: doc, jsdoc, public-api, side-effects
---

## JSDoc for Public APIs and Non-Obvious Side Effects

TypeScript types describe the shape of a value; JSDoc adds intent, side effects, and constraints that types cannot express. Critically, JSDoc on exported symbols renders in consumer IDEs at the call site — so for library functions, custom hooks, and shared utilities, JSDoc is documentation that travels with the symbol.

**Incorrect (consumer must read the implementation to discover side effects):**

```tsx
// Exported hook with no JSDoc — call sites have no warning that this
// subscribes to storage events and re-renders the component on cross-tab
// activity. Consumer learns this only by spelunking the source.
export function useAuthSession() {
  const [session, setSession] = useState<Session | null>(() => readSession());

  useEffect(() => {
    const onStorage = (e: StorageEvent) => {
      if (e.key === 'auth') setSession(readSession());
    };
    const onFocus = () => setSession(readSession());
    window.addEventListener('storage', onStorage);
    window.addEventListener('focus', onFocus);
    return () => {
      window.removeEventListener('storage', onStorage);
      window.removeEventListener('focus', onFocus);
    };
  }, []);

  return session;
}
```

**Correct (intent and side effects visible on hover):**

```tsx
/**
 * Reads the current auth session and keeps it in sync across tabs.
 *
 * Side effects:
 *  - Subscribes to `window` `storage` events (cross-tab logout/login).
 *  - Subscribes to `window` `focus` to refresh on tab return.
 *
 * Re-renders the calling component whenever the session changes.
 *
 * @returns The current session, or `null` if logged out.
 */
export function useAuthSession() {
  const [session, setSession] = useState<Session | null>(() => readSession());
  // ... same implementation ...
  return session;
}
```

**When NOT to apply this pattern:**
- Internal helpers whose only call sites live in the same module — the implementation IS the documentation, and JSDoc just duplicates it.
- Trivial signatures where the name and types are self-explanatory (`function add(a: number, b: number): number`).
- Package-private modules not exported from the package entry point — consumers can't reach them, so the IDE-tooltip benefit doesn't apply.

**Why this matters:** Consumers form their mental model from what they see at the call site. JSDoc is the only documentation that travels there.

Reference: [Clean Code, Chapter 4: Comments](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [TSDoc specification](https://tsdoc.org/)
