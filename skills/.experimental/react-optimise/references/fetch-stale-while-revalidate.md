---
title: Use Stale-While-Revalidate for Cache Freshness
impact: HIGH
impactDescription: 0ms perceived load time for returning visitors
tags: fetch, stale-while-revalidate, caching, perceived-performance
---

## Use Stale-While-Revalidate for Cache Freshness

Showing a loading spinner on every page visit forces users to wait for the full network round trip. Stale-while-revalidate displays cached data instantly and refreshes it in the background, giving returning visitors a 0ms perceived load time while keeping data fresh.

**Incorrect (loading spinner on every visit):**

```tsx
import { useEffect, useState } from "react"

interface TeamMember {
  id: string
  name: string
  role: string
  avatarUrl: string
}

function TeamDirectory() {
  const [members, setMembers] = useState<TeamMember[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    setLoading(true) // spinner shown even when data hasn't changed
    fetchTeamMembers().then((data) => {
      setMembers(data)
      setLoading(false)
    })
  }, [])

  if (loading) return <DirectorySkeleton />

  return (
    <ul>
      {members.map((member) => (
        <li key={member.id}>
          <img src={member.avatarUrl} alt={member.name} />
          <span>{member.name}</span>
          <span>{member.role}</span>
        </li>
      ))}
    </ul>
  )
}
```

**Correct (instant cached data, background refresh):**

```tsx
import { useQuery } from "@tanstack/react-query"

interface TeamMember {
  id: string
  name: string
  role: string
  avatarUrl: string
}

function TeamDirectory() {
  const { data: members, isLoading } = useQuery({
    queryKey: ["teamMembers"],
    queryFn: fetchTeamMembers,
    staleTime: 60_000,       // data considered fresh for 60 seconds
    gcTime: 5 * 60_000,      // cached data kept for 5 minutes
  })

  if (isLoading) return <DirectorySkeleton /> // only on first visit

  return (
    <ul>
      {members!.map((member) => (
        <li key={member.id}>
          <img src={member.avatarUrl} alt={member.name} />
          <span>{member.name}</span>
          <span>{member.role}</span>
        </li>
      ))}
    </ul>
  )
}
```

Reference: [TanStack Query — Caching](https://tanstack.com/query/latest/docs/framework/react/guides/caching)
