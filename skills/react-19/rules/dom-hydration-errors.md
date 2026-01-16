---
title: Handle Hydration Mismatches Properly
impact: LOW-MEDIUM
impactDescription: prevents cryptic errors, improves debugging experience
tags: dom, hydration, ssr, debugging
---

## Handle Hydration Mismatches Properly

React 19 provides better hydration error messages, but mismatches still cause issues. Understand common causes and how to avoid them.

**Incorrect (hydration mismatch):**

```tsx
function Timestamp() {
  // Different value on server vs client
  return <span>{new Date().toLocaleTimeString()}</span>
}
// Server: "10:30:00 AM"
// Client: "10:30:01 AM"
// Hydration mismatch!
```

**Correct (suppress hydration for dynamic content):**

```tsx
function Timestamp() {
  const [time, setTime] = useState<string | null>(null)

  useEffect(() => {
    setTime(new Date().toLocaleTimeString())
    const interval = setInterval(() => {
      setTime(new Date().toLocaleTimeString())
    }, 1000)
    return () => clearInterval(interval)
  }, [])

  if (!time) return <span>--:--:--</span>  // Placeholder matches server

  return <span>{time}</span>
}
```

**Alternative (suppressHydrationWarning):**

```tsx
function Timestamp() {
  return (
    <span suppressHydrationWarning>
      {new Date().toLocaleTimeString()}
    </span>
  )
}
// Use sparingly - only for intentional mismatches
```

**Common hydration mismatch causes:**
- Time-based content
- Browser-specific APIs (window, localStorage)
- Random values
- User agent detection
- Third-party scripts modifying DOM

Reference: [Hydration Errors](https://react.dev/blog/2024/12/05/react-19#improvements-to-hydration-error-reporting)
