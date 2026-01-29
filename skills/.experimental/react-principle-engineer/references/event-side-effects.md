---
title: Event handlers are the primary place for side effects
impact: HIGH
impactDescription: User-triggered side effects (API calls, navigation, mutations) belong in event handlers, not render or effects
tags: [event, side-effects, handlers, api-calls, mutations]
---

# Event Handlers Are the Primary Place for Side Effects

When something should happen in response to a user action, put it directly in the event handler. This is the most natural and direct way to handle side effects.

## Why Event Handlers

```tsx
// Event handlers are:
// - Called in response to specific user actions
// - Not called during render (pure render)
// - The natural place for "when user does X, do Y"
// - Synchronous with the action that triggered them
```

## Common Side Effects in Handlers

```tsx
function TodoApp() {
  const [todos, setTodos] = useState<Todo[]>([]);

  // API calls
  async function handleAddTodo(text: string) {
    const newTodo = await api.createTodo(text);
    setTodos([...todos, newTodo]);
  }

  // Navigation
  function handleLogout() {
    auth.logout();
    navigate('/login');
  }

  // Analytics
  function handlePurchase(item: Item) {
    analytics.track('purchase', { item: item.id });
    cart.checkout(item);
  }

  // Local storage
  function handleSavePreferences(prefs: Preferences) {
    localStorage.setItem('prefs', JSON.stringify(prefs));
    setPreferences(prefs);
  }
}
```

## Don't Use Effect for Event Logic

```tsx
// Problem: Effect watching for "submitted" flag
function Form() {
  const [submitted, setSubmitted] = useState(false);

  useEffect(() => {
    if (submitted) {
      sendData(formData);
      showToast('Submitted!');
      setSubmitted(false);
    }
  }, [submitted, formData]);

  function handleSubmit() {
    setSubmitted(true);  // Just to trigger effect
  }
}

// Solution: Side effects directly in handler
function Form() {
  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    await sendData(formData);
    showToast('Submitted!');
  }

  return <form onSubmit={handleSubmit}>...</form>;
}
```

## Async Event Handlers

```tsx
function SearchButton() {
  const [isLoading, setIsLoading] = useState(false);
  const [results, setResults] = useState<Result[]>([]);

  // Async handlers work great
  async function handleSearch() {
    setIsLoading(true);
    try {
      const data = await api.search(query);
      setResults(data);
    } catch (error) {
      showError(error.message);
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <button onClick={handleSearch} disabled={isLoading}>
      {isLoading ? 'Searching...' : 'Search'}
    </button>
  );
}
```

## Handlers vs Effects: Decision Guide

```tsx
// USER ACTION → Handler
// "When user clicks, save to server"
function handleClick() {
  saveToServer(data);
}

// SYNCHRONIZATION → Effect
// "Keep localStorage in sync with state"
useEffect(() => {
  localStorage.setItem('data', JSON.stringify(data));
}, [data]);

// But even this could be in handler if it's user-initiated:
function handleSave() {
  localStorage.setItem('data', JSON.stringify(data));
}
```

## Error Handling in Handlers

```tsx
function DeleteButton({ itemId }: { itemId: string }) {
  const [error, setError] = useState<string | null>(null);

  async function handleDelete() {
    setError(null);
    try {
      await api.deleteItem(itemId);
      onSuccess();
    } catch (e) {
      setError('Failed to delete. Please try again.');
    }
  }

  return (
    <div>
      <button onClick={handleDelete}>Delete</button>
      {error && <span className="error">{error}</span>}
    </div>
  );
}
```

## Key Principle

Event handlers = side effects in response to user actions. They run at a specific moment (when the event fires), making cause and effect clear. This is usually simpler than routing through state and effects.
