---
title: Extract duplicated effect/state shapes into a shared hook
impact: HIGH
impactDescription: collapses 2+ near-identical effect/state blocks into one source of truth, reduces drift between copies
tags: cross, duplication, custom-hook, extract, refactor
---

## Extract duplicated effect/state shapes into a shared hook

**This is a cross-cutting rule.** It cannot be detected by reading a single file — you must read 2+ files and recognize the same effect/state shape repeating.

### Shapes to recognize

- Two or more components running the same `useEffect(fetch ...).then(setX)` against different endpoints, with the same loading/error/data tri-state in `useState`.
- Two or more components subscribing to the same DOM event (`resize`, `scroll`, `keydown`) and tracking the result in local state.
- Two or more components reading the same `localStorage`/`sessionStorage` key with the same JSON-parse-on-read, JSON-stringify-on-write dance.
- Two or more components using `useState + setInterval` to drive a "current time" or polling tick.
- A custom hook that *appears* unique but is structurally the same as another (e.g. `useUserData(id)` and `useMemberData(id)` differ only by URL).

### Detection procedure

1. After completing Categories 1–8, list every `useEffect` body in the inventory, grouped by shape (ignore endpoint strings, focus on the structure).
2. For each group with 2+ members, ask: *would a `useResource(endpoint)` hook eliminate this?*
3. The threshold is **2 occurrences**, not 3 — by the time you have 3, the drift has already started.

### Multi-file example

**Incorrect (three files, three near-identical fetches):**

```typescript
// src/profile/Profile.tsx
function Profile({ id }: { id: string }) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)
  useEffect(() => {
    setLoading(true)
    fetch(`/api/users/${id}`)
      .then(r => r.json())
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false))
  }, [id])
  // ...
}

// src/team/TeamMember.tsx
function TeamMember({ id }: { id: string }) {
  const [member, setMember] = useState<Member | null>(null)
  const [isLoading, setIsLoading] = useState(true)  // drift: `isLoading` vs `loading`
  const [err, setErr] = useState<Error | null>(null) // drift: `err` vs `error`
  useEffect(() => {
    setIsLoading(true)
    fetch(`/api/members/${id}`)
      .then(r => r.json())
      .then(setMember)
      .catch(setErr)
      .finally(() => setIsLoading(false))
  }, [id])
  // ...
}

// src/billing/Account.tsx
function Account({ id }: { id: string }) {
  const [account, setAccount] = useState<Account | null>(null)
  const [pending, setPending] = useState(true) // drift: yet another name
  // ... same shape, different field names
}
```

Three components, three subtly different shapes, three places to fix when the API changes.

**Correct (one hook, three callers):**

```typescript
// src/lib/useResource.ts
export function useResource<T>(url: string) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)
  useEffect(() => {
    const controller = new AbortController()
    setLoading(true)
    fetch(url, { signal: controller.signal })
      .then(r => r.json())
      .then(d => { if (!controller.signal.aborted) setData(d) })
      .catch(e => { if (!controller.signal.aborted) setError(e) })
      .finally(() => { if (!controller.signal.aborted) setLoading(false) })
    return () => controller.abort()
  }, [url])
  return { data, loading, error }
}

// src/profile/Profile.tsx
function Profile({ id }: { id: string }) {
  const { data: user, loading, error } = useResource<User>(`/api/users/${id}`)
  // ...
}

// (TeamMember and Account follow the same pattern.)
```

One source of truth for fetch semantics — abort, error type, loading lifecycle. When the team adopts `use(promise)` + Suspense (see [`data-use-hook.md`](data-use-hook.md)), they change it in one place.

### When NOT to extract

- The two shapes happen to look alike but are conceptually different (e.g. a polling fetch vs a one-shot fetch — the shared hook would need a `mode` parameter that pollutes both callers).
- One caller is server-side and the other client-side — the abstraction boundary should be Server vs Client, not "fetch."
- The duplication is two occurrences of trivial code (3–4 lines). Wait for the third.

### Risk before extracting

- Check if any of the call sites are exported to consumers outside the repo (extracting changes the import surface).
- Check if the differences between copies encode behavior the maintainers may have forgotten — diff them carefully before collapsing.

Reference: [Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
