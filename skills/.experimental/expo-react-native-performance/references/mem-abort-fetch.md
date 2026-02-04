---
title: Abort Fetch Requests on Unmount
impact: MEDIUM
impactDescription: prevents memory leaks from pending requests
tags: mem, abort-controller, fetch, cleanup
---

## Abort Fetch Requests on Unmount

Pending fetch requests continue even after unmount. When they resolve, attempting to update state on an unmounted component causes memory leaks. Use AbortController to cancel requests.

**Incorrect (fetch continues after unmount):**

```typescript
// screens/UserProfile.tsx
export function UserProfile({ userId }: Props) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    fetch(`/api/users/${userId}`)
      .then((res) => res.json())
      .then(setUser);  // May run after unmount
  }, [userId]);

  return user ? <ProfileView user={user} /> : <Loading />;
}
// If user navigates away during fetch, response still processed
```

**Correct (abort request on unmount):**

```typescript
// screens/UserProfile.tsx
export function UserProfile({ userId }: Props) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const controller = new AbortController();

    fetch(`/api/users/${userId}`, { signal: controller.signal })
      .then((res) => res.json())
      .then(setUser)
      .catch((err) => {
        if (err.name !== 'AbortError') throw err;
      });

    return () => {
      controller.abort();
    };
  }, [userId]);

  return user ? <ProfileView user={user} /> : <Loading />;
}
// Request cancelled when component unmounts or userId changes
```

**With async/await:**

```typescript
useEffect(() => {
  const controller = new AbortController();

  async function loadUser() {
    try {
      const res = await fetch(`/api/users/${userId}`, { signal: controller.signal });
      const data = await res.json();
      setUser(data);
    } catch (err) {
      if (err.name !== 'AbortError') throw err;
    }
  }

  loadUser();
  return () => controller.abort();
}, [userId]);
```

Reference: [AbortController](https://developer.mozilla.org/en-US/docs/Web/API/AbortController)
