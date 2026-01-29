---
title: Remove unnecessary effects
impact: HIGH
impactDescription: Many effects can be eliminated by calculating during render or moving logic to event handlers
tags: [effect, optimization, simplification, render]
---

# Remove Unnecessary Effects

Before writing an Effect, ask if you need one. Many things developers put in Effects should be calculated during render or in event handlers.

## Why This Matters

Fewer Effects means:
- Less code to maintain
- Fewer re-render cycles
- Clearer data flow
- Better performance

## You Don't Need an Effect to Transform Data

```tsx
// Problem: Transforming data in effect
function ProductList({ products }: { products: Product[] }) {
  const [sortedProducts, setSortedProducts] = useState<Product[]>([]);
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc');

  useEffect(() => {
    const sorted = [...products].sort((a, b) =>
      sortOrder === 'asc' ? a.price - b.price : b.price - a.price
    );
    setSortedProducts(sorted);
  }, [products, sortOrder]);

  return <List items={sortedProducts} />;
}

// Solution: Calculate during render
function ProductList({ products }: { products: Product[] }) {
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc');

  const sortedProducts = [...products].sort((a, b) =>
    sortOrder === 'asc' ? a.price - b.price : b.price - a.price
  );

  return <List items={sortedProducts} />;
}
```

## You Don't Need an Effect to Handle User Events

```tsx
// Problem: Effect watching for "submit" state
function Form() {
  const [formData, setFormData] = useState({ email: '' });
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (isSubmitting) {
      submitForm(formData).then(() => {
        setIsSubmitting(false);
        showSuccess();
      });
    }
  }, [isSubmitting, formData]);

  return (
    <form onSubmit={() => setIsSubmitting(true)}>
      ...
    </form>
  );
}

// Solution: Handle in event handler
function Form() {
  const [formData, setFormData] = useState({ email: '' });

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    await submitForm(formData);
    showSuccess();
  }

  return (
    <form onSubmit={handleSubmit}>
      ...
    </form>
  );
}
```

## You Don't Need an Effect to Initialize State

```tsx
// Problem: Effect to set initial state from props
function Timer({ duration }: { duration: number }) {
  const [timeLeft, setTimeLeft] = useState(0);

  useEffect(() => {
    setTimeLeft(duration);
  }, [duration]);
}

// Solution: Initialize state with prop directly
function Timer({ duration }: { duration: number }) {
  const [timeLeft, setTimeLeft] = useState(duration);
  // Or if it should reset when duration changes:
  // Use key on parent: <Timer key={duration} duration={duration} />
}
```

## You Don't Need an Effect to Reset State on Prop Change

```tsx
// Problem: Effect to reset state
function ProfileEditor({ userId }: { userId: string }) {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');

  useEffect(() => {
    setName('');
    setEmail('');
  }, [userId]);
}

// Solution: Use key to reset component
function Parent() {
  const [userId, setUserId] = useState('1');
  return <ProfileEditor key={userId} userId={userId} />;
}

function ProfileEditor({ userId }: { userId: string }) {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  // Fresh state for each userId
}
```

## You Don't Need an Effect to Update Parent State

```tsx
// Problem: Effect to notify parent
function SearchInput({ onSearch }: { onSearch: (q: string) => void }) {
  const [query, setQuery] = useState('');

  useEffect(() => {
    onSearch(query);
  }, [query, onSearch]);

  return <input value={query} onChange={e => setQuery(e.target.value)} />;
}

// Solution: Call parent directly
function SearchInput({ onSearch }: { onSearch: (q: string) => void }) {
  const [query, setQuery] = useState('');

  function handleChange(e: ChangeEvent<HTMLInputElement>) {
    const newQuery = e.target.value;
    setQuery(newQuery);
    onSearch(newQuery);  // Call directly, same event
  }

  return <input value={query} onChange={handleChange} />;
}
```

## Effect Checklist

Before writing an Effect, ask:

1. **Can I calculate this during render?**
   - Derived values, filtered lists, etc.

2. **Is this responding to a user action?**
   - Button clicks, form submissions, etc.

3. **Can I use the key prop to reset?**
   - Resetting form state when ID changes

4. **Is this actually syncing with an external system?**
   - Network, DOM, timers, third-party libs

Only if #4 is true do you need an Effect.

## Valid Effects

```tsx
// YES: Syncing with WebSocket
useEffect(() => {
  const ws = new WebSocket(url);
  return () => ws.close();
}, [url]);

// YES: Syncing with browser API
useEffect(() => {
  document.title = title;
}, [title]);

// YES: Setting up subscription
useEffect(() => {
  return store.subscribe(listener);
}, [store]);
```

## Key Principle

Effects are escape hatches for synchronizing with external systems. If you're not syncing with something outside React, you probably don't need an Effect.
