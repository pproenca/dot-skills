---
title: Deduplicate Identical In-Flight Requests
impact: HIGH
impactDescription: reduces network requests by 50-80% in component-heavy pages
tags: fetch, deduplication, network, caching, shared-state
---

## Deduplicate Identical In-Flight Requests

When multiple components independently fetch the same endpoint, the browser sends duplicate network requests that waste bandwidth and increase server load. Request deduplication ensures that concurrent requests for the same resource share a single in-flight promise.

**Incorrect (three components fire three identical requests):**

```tsx
import { useEffect, useState } from "react"

interface UserProfile {
  id: string
  displayName: string
  avatarUrl: string
  plan: string
}

function NavigationBar() {
  const [user, setUser] = useState<UserProfile | null>(null)

  useEffect(() => {
    fetch("/api/user/me").then((r) => r.json()).then(setUser)
  }, [])

  return <nav>{user?.displayName}</nav>
}

function ProfileBadge() {
  const [user, setUser] = useState<UserProfile | null>(null)

  useEffect(() => {
    fetch("/api/user/me").then((r) => r.json()).then(setUser) // duplicate request
  }, [])

  return <img src={user?.avatarUrl} alt="Profile" />
}

function BillingBanner() {
  const [user, setUser] = useState<UserProfile | null>(null)

  useEffect(() => {
    fetch("/api/user/me").then((r) => r.json()).then(setUser) // third duplicate
  }, [])

  return user?.plan === "free" ? <UpgradeBanner /> : null
}
```

**Correct (single request shared across all consumers):**

```tsx
import { useQuery } from "@tanstack/react-query"

interface UserProfile {
  id: string
  displayName: string
  avatarUrl: string
  plan: string
}

function useCurrentUser() {
  return useQuery({
    queryKey: ["currentUser"],
    queryFn: () => fetch("/api/user/me").then((r) => r.json() as Promise<UserProfile>),
    staleTime: 30_000, // all consumers share one cached result
  })
}

function NavigationBar() {
  const { data: user } = useCurrentUser() // shares in-flight request
  return <nav>{user?.displayName}</nav>
}

function ProfileBadge() {
  const { data: user } = useCurrentUser() // reuses same promise
  return <img src={user?.avatarUrl} alt="Profile" />
}

function BillingBanner() {
  const { data: user } = useCurrentUser() // no additional network call
  return user?.plan === "free" ? <UpgradeBanner /> : null
}
```

Reference: [TanStack Query — Query Deduplication](https://tanstack.com/query/latest/docs/framework/react/guides/query-functions#query-function-sharing)
