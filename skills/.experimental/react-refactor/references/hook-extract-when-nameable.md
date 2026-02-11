---
title: Extract Logic into Custom Hooks When Behavior Is Nameable
impact: HIGH
impactDescription: makes component 40-60% shorter, behavior self-documenting
tags: hook, extraction, readability, abstraction
---

## Extract Logic into Custom Hooks When Behavior Is Nameable

Inline timer setup, event subscriptions, and cleanup logic obscure the component's intent behind implementation mechanics. When the behavior has a clear name — "countdown", "window resize", "online status" — extracting it into a custom hook replaces 10-15 lines of mechanism with a single descriptive call.

**Incorrect (inline timer + cleanup — behavior buried in mechanics):**

```tsx
function AuctionBidPanel({ endsAt }: { endsAt: Date }) {
  const [timeRemaining, setTimeRemaining] = useState<number>(0);
  const [isExpired, setIsExpired] = useState(false);

  useEffect(() => {
    function tick() {
      const remaining = endsAt.getTime() - Date.now();
      if (remaining <= 0) {
        setTimeRemaining(0);
        setIsExpired(true);
        return;
      }
      setTimeRemaining(remaining);
    }

    tick();
    const intervalId = setInterval(tick, 1000);
    return () => clearInterval(intervalId);
  }, [endsAt]);

  const hours = Math.floor(timeRemaining / 3_600_000);
  const minutes = Math.floor((timeRemaining % 3_600_000) / 60_000);
  const seconds = Math.floor((timeRemaining % 60_000) / 1_000);

  // 20 lines of timer plumbing before the actual UI begins
  return (
    <div>
      {isExpired ? <p>Auction ended</p> : <p>{hours}h {minutes}m {seconds}s</p>}
      <BidForm disabled={isExpired} />
    </div>
  );
}
```

**Correct (named hook — intent replaces mechanism):**

```tsx
function useCountdown(targetDate: Date) {
  const [timeRemaining, setTimeRemaining] = useState(targetDate.getTime() - Date.now());

  useEffect(() => {
    function tick() {
      const remaining = targetDate.getTime() - Date.now();
      setTimeRemaining(Math.max(0, remaining));
    }
    tick();
    const intervalId = setInterval(tick, 1000);
    return () => clearInterval(intervalId);
  }, [targetDate]);

  return {
    isExpired: timeRemaining <= 0,
    hours: Math.floor(timeRemaining / 3_600_000),
    minutes: Math.floor((timeRemaining % 3_600_000) / 60_000),
    seconds: Math.floor((timeRemaining % 60_000) / 1_000),
  };
}

function AuctionBidPanel({ endsAt }: { endsAt: Date }) {
  const { isExpired, hours, minutes, seconds } = useCountdown(endsAt);

  return (
    <div>
      {isExpired ? <p>Auction ended</p> : <p>{hours}h {minutes}m {seconds}s</p>}
      <BidForm disabled={isExpired} />
    </div>
  );
}
```

Reference: [React Docs - Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
