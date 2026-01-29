---
title: Don't use effects for event-driven logic
impact: HIGH
impactDescription: Side effects triggered by user actions should be in event handlers, not effects watching for state changes
tags: [effect, events, handlers, actions, user-input]
---

# Don't Use Effects for Event-Driven Logic

When something should happen in response to a user action, put it in the event handler. Effects are for synchronization, not for responding to events.

## Why This Matters

Event handlers for actions:
- Run exactly when the action happens
- Don't require intermediate state
- Make cause-and-effect clear
- Are simpler and more direct

## Incorrect: Effect Watching State

```tsx
// Problem: Using effect to respond to form submission
function Form() {
  const [data, setData] = useState('');
  const [isSubmitted, setIsSubmitted] = useState(false);

  // WRONG: Effect watching for submission
  useEffect(() => {
    if (isSubmitted) {
      sendToServer(data);
      showSuccessMessage();
    }
  }, [isSubmitted, data]);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setIsSubmitted(true);  // Trigger the effect
  }
}
```

## Correct: Logic in Event Handler

```tsx
// Solution: Side effect directly in handler
function Form() {
  const [data, setData] = useState('');

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    await sendToServer(data);
    showSuccessMessage();
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={data} onChange={e => setData(e.target.value)} />
      <button type="submit">Submit</button>
    </form>
  );
}
```

## Incorrect: Buy Button with Effect

```tsx
// Problem: Effect for purchase logic
function ProductPage({ product }: { product: Product }) {
  const [quantity, setQuantity] = useState(1);
  const [isPurchasing, setIsPurchasing] = useState(false);

  useEffect(() => {
    if (isPurchasing) {
      buy(product, quantity).then(() => {
        showConfirmation();
        setIsPurchasing(false);
      });
    }
  }, [isPurchasing, product, quantity]);

  return (
    <button onClick={() => setIsPurchasing(true)}>
      Buy
    </button>
  );
  // Problem: What if quantity changes while purchasing?
  // The effect might run again with wrong quantity!
}
```

## Correct: Purchase in Handler

```tsx
// Solution: Purchase logic in click handler
function ProductPage({ product }: { product: Product }) {
  const [quantity, setQuantity] = useState(1);
  const [isLoading, setIsLoading] = useState(false);

  async function handleBuy() {
    setIsLoading(true);
    await buy(product, quantity);
    showConfirmation();
    setIsLoading(false);
  }

  return (
    <button onClick={handleBuy} disabled={isLoading}>
      {isLoading ? 'Buying...' : 'Buy'}
    </button>
  );
  // quantity is captured at click time - correct!
}
```

## The Distinction

```tsx
// USER ACTION → Event Handler
// Click, type, submit, hover, etc.
function Button() {
  function handleClick() {
    analytics.track('button_click');  // Caused by user action
    doSomething();
  }
  return <button onClick={handleClick}>Click</button>;
}

// SYNC WITH EXTERNAL SYSTEM → Effect
// Keep connection alive, subscribe to data, etc.
function Chat({ roomId }: { roomId: string }) {
  useEffect(() => {
    const conn = connect(roomId);  // Sync with server
    return () => conn.disconnect();
  }, [roomId]);
}
```

## Mixed Case: Analytics

```tsx
// Page view analytics: EFFECT (sync with analytics on route change)
useEffect(() => {
  analytics.pageView(currentPage);
}, [currentPage]);

// Click analytics: EVENT HANDLER (response to user action)
function Button() {
  function handleClick() {
    analytics.click('cta_button');
    navigate('/signup');
  }
  return <button onClick={handleClick}>Sign Up</button>;
}
```

## Incorrect: Navigation Effect

```tsx
// Problem: Navigate in effect after state change
function Login() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  useEffect(() => {
    if (isLoggedIn) {
      navigate('/dashboard');
    }
  }, [isLoggedIn]);

  async function handleLogin() {
    await login();
    setIsLoggedIn(true);  // Triggers navigation via effect
  }
}
```

## Correct: Navigate in Handler

```tsx
// Solution: Navigate directly after successful login
function Login() {
  async function handleLogin() {
    await login();
    navigate('/dashboard');  // Direct, clear causation
  }

  return <button onClick={handleLogin}>Login</button>;
}
```

## Decision Guide

| Trigger | Where to Put Side Effect |
|---------|--------------------------|
| Button click | Event handler |
| Form submit | Event handler |
| User input | Event handler |
| Route change | Event handler (or effect for analytics) |
| Prop/state change (sync) | Effect |
| Component mount (setup) | Effect |

## Key Principle

Ask: "Why does this code need to run?" If the answer is "because the user did X," put it in the handler for X. If the answer is "to keep something in sync," use an Effect.
