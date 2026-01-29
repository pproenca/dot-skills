---
title: Avoid contradictory state
impact: HIGH
impactDescription: Mutually exclusive states stored as separate booleans can become impossible combinations, causing bugs
tags: [state, structure, enums, status, booleans]
---

# Avoid Contradictory State

When you have multiple boolean flags that represent status, they can get into "impossible" states. Use a single status variable with explicit states instead.

## Why This Matters

Contradictory state:
- Creates impossible combinations (both loading AND error)
- Requires remembering to update multiple flags correctly
- Makes the valid states unclear to other developers
- Leads to subtle bugs that are hard to reproduce

**Incorrect (anti-pattern):**

```tsx
// Problem: Two booleans that should never both be true
function FeedbackForm() {
  const [text, setText] = useState('');
  const [isSending, setIsSending] = useState(false);
  const [isSent, setIsSent] = useState(false);

  async function handleSubmit() {
    setIsSending(true);
    await sendFeedback(text);
    setIsSending(false);
    setIsSent(true);
  }

  // BUG: What if setIsSent is called without setIsSending(false)?
  // You'd have both isSending=true AND isSent=true
  // This is an "impossible" state that shouldn't exist

  if (isSent) {
    return <p>Thanks for your feedback!</p>;
  }

  return (
    <form onSubmit={handleSubmit}>
      <textarea value={text} onChange={e => setText(e.target.value)} />
      <button disabled={isSending}>
        {isSending ? 'Sending...' : 'Send'}
      </button>
    </form>
  );
}
```

**Correct (recommended):**

```tsx
// Solution: Single status with explicit states
type FormStatus = 'typing' | 'sending' | 'sent';

function FeedbackForm() {
  const [text, setText] = useState('');
  const [status, setStatus] = useState<FormStatus>('typing');

  async function handleSubmit() {
    setStatus('sending');
    await sendFeedback(text);
    setStatus('sent');
  }

  // Impossible to be in multiple states at once

  if (status === 'sent') {
    return <p>Thanks for your feedback!</p>;
  }

  const isSending = status === 'sending';

  return (
    <form onSubmit={handleSubmit}>
      <textarea
        value={text}
        onChange={e => setText(e.target.value)}
        disabled={isSending}
      />
      <button disabled={isSending}>
        {isSending ? 'Sending...' : 'Send'}
      </button>
    </form>
  );
}
```

**Incorrect (anti-pattern):**

```tsx
// Problem: Three booleans for fetch state
function UserProfile({ userId }: { userId: string }) {
  const [isLoading, setIsLoading] = useState(false);
  const [hasError, setHasError] = useState(false);
  const [hasData, setHasData] = useState(false);
  const [user, setUser] = useState<User | null>(null);

  // 8 possible combinations of booleans
  // Only 4 are valid: idle, loading, success, error
  // The other 4 are bugs waiting to happen
}
```

**Correct (recommended):**

```tsx
// Solution: Discriminated union makes states explicit
type FetchState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

function UserProfile({ userId }: { userId: string }) {
  const [state, setState] = useState<FetchState<User>>({ status: 'idle' });

  useEffect(() => {
    setState({ status: 'loading' });

    fetchUser(userId)
      .then(user => setState({ status: 'success', data: user }))
      .catch(error => setState({ status: 'error', error }));
  }, [userId]);

  switch (state.status) {
    case 'idle':
      return null;
    case 'loading':
      return <Spinner />;
    case 'error':
      return <ErrorMessage error={state.error} />;
    case 'success':
      return <UserCard user={state.data} />;
  }
}
```

## Signs of Contradictory State

```tsx
// RED FLAGS in your code:

// Multiple boolean flags for status
const [isLoading, setIsLoading] = useState(false);
const [isError, setIsError] = useState(false);
const [isSuccess, setIsSuccess] = useState(false);

// Defensive code checking "impossible" combinations
if (isLoading && isError) {
  // This shouldn't happen, but just in case...
}

// Complex if/else chains determining current state
if (isLoading) {
  // ...
} else if (isError) {
  // ...
} else if (isSuccess) {
  // ...
} else {
  // idle? what if isSuccess and isError are both false?
}
```

## The Fix: Enumerate Valid States

```tsx
// List all the valid states your component can be in
type ModalState =
  | 'closed'
  | 'opening'
  | 'open'
  | 'closing';

type FormState =
  | 'editing'
  | 'validating'
  | 'submitting'
  | 'submitted'
  | 'error';

type MediaState =
  | 'idle'
  | 'loading'
  | 'playing'
  | 'paused'
  | 'ended'
  | 'error';
```

## Key Principle

If you can draw a state machine where each node is a valid state, your state variable should match those nodes - not the transitions between them. If "loading AND error" is impossible, don't let your code represent it.
