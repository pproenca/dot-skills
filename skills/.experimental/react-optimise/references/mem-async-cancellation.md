---
title: Cancel Async Operations on Unmount
impact: LOW-MEDIUM
impactDescription: prevents stale updates and memory retention
tags: mem, async, abort-controller, cancellation
---

## Cancel Async Operations on Unmount

Fetch requests and async operations that complete after a component unmounts attempt to update state on an unmounted component. The in-flight response holds a reference to the component's closure, preventing garbage collection until the request completes.

**Incorrect (fetch continues after unmount, sets state on dead component):**

```tsx
function UserProfile({ userId }: { userId: string }) {
  const [profile, setProfile] = useState<UserData | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    setIsLoading(true)

    fetch(`/api/users/${userId}`)
      .then((response) => response.json())
      .then((userData: UserData) => {
        setProfile(userData) // fires even if component already unmounted
        setIsLoading(false)
      })
      .catch((error) => {
        console.error("Failed to load profile:", error)
        setIsLoading(false)
      })
    // No cancellation — navigating away mid-request keeps closure alive
  }, [userId])

  if (isLoading) return <ProfileSkeleton />
  return <ProfileCard profile={profile!} />
}
```

**Correct (AbortController cancels request on unmount or userId change):**

```tsx
function UserProfile({ userId }: { userId: string }) {
  const [profile, setProfile] = useState<UserData | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const controller = new AbortController()
    setIsLoading(true)

    fetch(`/api/users/${userId}`, { signal: controller.signal })
      .then((response) => response.json())
      .then((userData: UserData) => {
        setProfile(userData)
        setIsLoading(false)
      })
      .catch((error) => {
        if (error.name !== "AbortError") {
          console.error("Failed to load profile:", error)
          setIsLoading(false)
        }
      })

    return () => {
      controller.abort() // cancels in-flight request, releases closure
    }
  }, [userId])

  if (isLoading) return <ProfileSkeleton />
  return <ProfileCard profile={profile!} />
}
```

Reference: [MDN — AbortController](https://developer.mozilla.org/en-US/docs/Web/API/AbortController)
