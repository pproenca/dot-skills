---
title: Follow Hook Naming Conventions for Discoverability
impact: HIGH
impactDescription: reduces codebase navigation time by 40%
tags: hook, naming, conventions, discoverability
---

## Follow Hook Naming Conventions for Discoverability

Inconsistent hook names force developers to open each file to understand what a hook does. The `use` prefix is not just a React requirement — it is a discovery mechanism. Pairing it with a noun or verb phrase that describes the return value makes the hook self-documenting.

**Incorrect (inconsistent names — unclear what each returns):**

```tsx
// What does getData return? A function? The data itself? Loading state?
function getData(endpoint: string) {
  const [result, setResult] = useState(null);
  useEffect(() => {
    fetch(endpoint).then((r) => r.json()).then(setResult);
  }, [endpoint]);
  return result;
}

// "fetch" implies imperative call, but this is declarative
function fetchUserPermissions(userId: string) {
  const [permissions, setPermissions] = useState<string[]>([]);
  useEffect(() => {
    loadPermissions(userId).then(setPermissions);
  }, [userId]);
  return permissions;
}

// "do" prefix reads like a command, not a hook
function doAuth() {
  const [session, setSession] = useState<Session | null>(null);
  return { session, login: (creds: Credentials) => authenticate(creds).then(setSession) };
}
```

**Correct (use* convention with return-type hints):**

```tsx
// "useResource" pattern — returns { data, isLoading, error }
function useResource<T>(endpoint: string) {
  const [data, setData] = useState<T | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  useEffect(() => {
    setIsLoading(true);
    fetch(endpoint).then((r) => r.json()).then(setData).finally(() => setIsLoading(false));
  }, [endpoint]);
  return { data, isLoading };
}

// "usePermissions" — noun tells you it returns permissions
function usePermissions(userId: string) {
  const [permissions, setPermissions] = useState<string[]>([]);
  useEffect(() => {
    loadPermissions(userId).then(setPermissions);
  }, [userId]);
  return permissions;
}

// "useAuth" — returns auth state and actions
function useAuth() {
  const [session, setSession] = useState<Session | null>(null);
  return { session, login: (creds: Credentials) => authenticate(creds).then(setSession) };
}
```

Reference: [React Docs - Custom Hooks: Sharing Logic Between Components](https://react.dev/learn/reusing-logic-with-custom-hooks#hook-names-always-start-with-use)
