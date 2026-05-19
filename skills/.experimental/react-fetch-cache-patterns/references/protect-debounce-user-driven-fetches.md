---
title: Debounce User-Driven Fetches
impact: HIGH
impactDescription: 10-30× reduction in search/filter requests
tags: protect, debounce, search, typeahead, user-input
---

## Debounce User-Driven Fetches

A search input bound to a fetch fires one request per keystroke. Type "headphones" and the backend sees 10 search requests: "h", "he", "hea", "head", ..., "headphones". Only the last is the user's actual intent — the prefixes are byproducts of typing speed. Debounce: delay the fetch until the user pauses typing.

Pair debounce with request cancellation ([[resilience-abort-on-unmount]]) so that responses for stale prefixes don't overwrite the final results.

**Incorrect (fetch on every keystroke):**

```tsx
function Search() {
  const [term, setTerm] = useState('');
  const { data } = useQuery({
    queryKey: ['search', term],
    queryFn: () => searchProducts(term),
    enabled: term.length >= 2,
  });
  return <input value={term} onChange={e => setTerm(e.target.value)} />;
}
// User types "headphones" in 1.5s → 10 backend requests, 9 wasted
```

**Correct (debounce — fetch after user pauses):**

```tsx
import { useDebounce } from 'use-debounce'; // or your own hook

function Search() {
  const [term, setTerm] = useState('');
  const [debouncedTerm] = useDebounce(term, 300); // wait 300ms after last keystroke

  const { data } = useQuery({
    queryKey: ['search', debouncedTerm],
    queryFn: ({ signal }) => searchProducts(debouncedTerm, { signal }),
    enabled: debouncedTerm.length >= 2,
    placeholderData: keepPreviousData,
  });
  return <input value={term} onChange={e => setTerm(e.target.value)} />;
}
// User types "headphones" in 1.5s → 1 request (after the pause)
```

**Implementation (no dependency):**

```ts
export function useDebounce<T>(value: T, delayMs: number): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const t = setTimeout(() => setDebounced(value), delayMs);
    return () => clearTimeout(t);
  }, [value, delayMs]);
  return debounced;
}
```

**Tuning the delay:**
- Typeahead/autocomplete: 150-250ms (snappy)
- Filter chips, range sliders: 300-500ms
- Slider scrubbing (e.g. price range): 500-800ms (user keeps moving)

**Pair with [[resilience-abort-on-unmount]]:** debounce reduces the *count*; cancellation prevents a slow earlier response from clobbering a fast later one.

Reference: [React — Debouncing Hooks](https://react.dev/reference/react/useDeferredValue) | [use-debounce](https://github.com/xnimorz/use-debounce)
