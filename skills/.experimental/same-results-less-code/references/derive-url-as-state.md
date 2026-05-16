---
title: Let the URL or Route Be the State, Not a Mirror of It
impact: HIGH
impactDescription: eliminates URL-vs-local-state desync and the listener code that papers over it
tags: derive, url, state, routing
---

## Let the URL or Route Be the State, Not a Mirror of It

For things the URL already represents — current tab, search query, page number, selected entity id — the URL *is* the state, and the engineer's job is to read it. Mirroring it into local component state creates two truths: now any change must update both, and any external source (a deep link, a back button, a refresh) finds them out of sync. The judgment skill is recognising that browser routing already solves "what is the user looking at?" and not building a parallel system.

**Incorrect (URL and local state both track the same fact):**

```tsx
function SearchPage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const [query, setQuery] = useState(searchParams.get('q') ?? '');
  const [page, setPage]   = useState(Number(searchParams.get('page') ?? '1'));

  // Keep local state in sync with URL:
  useEffect(() => { setQuery(searchParams.get('q') ?? ''); }, [searchParams]);
  useEffect(() => { setPage(Number(searchParams.get('page') ?? '1')); }, [searchParams]);

  const handleSearch = (q: string) => {
    setQuery(q);                                          // local
    setSearchParams({ q, page: '1' });                    // URL
    setPage(1);                                           // local again
    // Three updates for one user action. If you forget one, the bug is "page resets on type"
    // or "URL doesn't reflect query." Both have happened to everyone who wrote this code.
  };
  // ...
}
```

**Correct (the URL is the state; derive everything else from it):**

```tsx
function SearchPage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const query = searchParams.get('q') ?? '';
  const page  = Number(searchParams.get('page') ?? '1');

  const handleSearch = (q: string) => {
    setSearchParams({ q, page: '1' });
  };
  // One source of truth. Refresh, back, deep link — all work without extra wiring.
}
```

**The same idea applies beyond URLs:**

- **Form library state.** If react-hook-form (or your form lib) already tracks the value, don't copy it into local state.
- **Query cache.** If TanStack Query / SWR holds the data, don't copy it into a `const [data]` mirror.
- **Server cookies / sessions.** If the server tells you who the user is, don't also track it client-side and reconcile.
- **Route params.** `id` from `useParams()` is the state — don't `useState` a copy.

**Symptoms:**

- An effect that copies router state into local state.
- A handler that calls two setters: one for URL, one for local.
- Tests for "URL and local state agree" assertions.
- Bug pattern: "back button takes me to the right URL but the page shows the previous query."

**When NOT to use this pattern:**

- You need a debounced *staging* state before committing to the URL (don't push to URL on every keystroke). Then the local state has a real role: it holds the in-progress value. The committed state is still the URL.
- The URL is shared and you don't want every transient UI change to appear in browser history — use `replace`, not `push`, but still keep the URL as the truth.

Reference: [TkDodo — Don't over useState](https://tkdodo.eu/blog/dont-over-use-state), [Nuqs docs](https://nuqs.47ng.com/)
