---
title: Never Interrupt an Active Search with a Conversion Modal
impact: MEDIUM-HIGH
impactDescription: prevents task-flow rejection
tags: convert, timing, fogg
---

## Never Interrupt an Active Search with a Conversion Modal

The Fogg Behavior Model is clear that triggers fired while the user is in the middle of a task flow produce rejection because the trigger competes with the task for attention and usually loses. A visitor actively browsing listings is executing a task (evaluating candidates) and an unrelated upgrade modal is exactly the kind of interrupter that gets dismissed reflexively. The right paywall timing is at natural pause points — when the visitor finishes scrolling a result page, when they click a specific listing that requires membership to proceed, when they return in a second session — not when they are mid-scroll or mid-comparison.

**Incorrect (time-based modal interrupts active browsing):**

```typescript
function SearchPage() {
  useEffect(() => {
    const timer = setTimeout(() => showUpgradeModal(), 30_000)
    return () => clearTimeout(timer)
  }, [])
  return <Listings />
}
```

**Correct (paywall triggered at natural pause points):**

```typescript
function SearchPage() {
  const [showPaywall, setShowPaywall] = useState(false)

  useEffect(() => {
    const onScrollPastEnd = () => setShowPaywall(true)
    window.addEventListener("scroll_past_end", onScrollPastEnd)
    return () => window.removeEventListener("scroll_past_end", onScrollPastEnd)
  }, [])

  function onListingAction(listing: Listing, action: "message" | "apply") {
    if (!currentUser.isMember) {
      setShowPaywall(true, { triggeringListing: listing, triggeringAction: action })
    } else {
      performAction(listing, action)
    }
  }

  return (
    <>
      <Listings onListingAction={onListingAction} />
      {showPaywall && <PaywallModal />}
    </>
  )
}
```

Reference: [BJ Fogg — A Behavior Model for Persuasive Design](https://bjfogg.com/fbm_files/page4_1.pdf)
