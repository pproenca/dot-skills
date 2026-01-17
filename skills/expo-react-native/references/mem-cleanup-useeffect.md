---
title: Clean Up Subscriptions and Timers in useEffect
impact: LOW-MEDIUM
impactDescription: prevents memory leaks from orphaned listeners and timers
tags: mem, useEffect, cleanup, subscriptions, timers
---

## Clean Up Subscriptions and Timers in useEffect

Always return a cleanup function from useEffect when creating subscriptions, timers, or event listeners. Failing to clean up causes memory leaks that compound over time.

**Incorrect (no cleanup, memory leak):**

```typescript
function LocationTracker() {
  const [location, setLocation] = useState(null)

  useEffect(() => {
    // Subscription never removed on unmount
    Location.watchPositionAsync(
      { accuracy: Location.Accuracy.High },
      (newLocation) => setLocation(newLocation)
    )
  }, [])

  return <MapView location={location} />
}
// Location updates continue after component unmounts
```

**Correct (cleanup on unmount):**

```typescript
function LocationTracker() {
  const [location, setLocation] = useState(null)

  useEffect(() => {
    let subscription

    const startTracking = async () => {
      subscription = await Location.watchPositionAsync(
        { accuracy: Location.Accuracy.High },
        (newLocation) => setLocation(newLocation)
      )
    }

    startTracking()

    return () => {
      subscription?.remove()  // Clean up on unmount
    }
  }, [])

  return <MapView location={location} />
}
```

**Timer cleanup:**

```typescript
function AutoRefresh({ onRefresh }) {
  useEffect(() => {
    const intervalId = setInterval(() => {
      onRefresh()
    }, 30000)

    return () => clearInterval(intervalId)  // Clean up timer
  }, [onRefresh])

  return null
}
```

**Event listener cleanup:**

```typescript
function KeyboardAwareView({ children }) {
  const [keyboardHeight, setKeyboardHeight] = useState(0)

  useEffect(() => {
    const showSubscription = Keyboard.addListener('keyboardDidShow', (e) => {
      setKeyboardHeight(e.endCoordinates.height)
    })
    const hideSubscription = Keyboard.addListener('keyboardDidHide', () => {
      setKeyboardHeight(0)
    })

    return () => {
      showSubscription.remove()
      hideSubscription.remove()
    }
  }, [])

  return <View style={{ paddingBottom: keyboardHeight }}>{children}</View>
}
```

**Common cleanup needs:**
- WebSocket connections
- Location/sensor subscriptions
- Keyboard listeners
- App state listeners
- setInterval/setTimeout
- Notification listeners

Reference: [useEffect Cleanup Documentation](https://react.dev/learn/synchronizing-with-effects#step-3-add-cleanup-if-needed)
