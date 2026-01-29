---
title: Why purity unlocks React's power
impact: MEDIUM
impactDescription: Pure components enable caching, concurrent rendering, server components, and all of React's optimization strategies
tags: [pure, performance, optimization, architecture]
---

# Why Purity Unlocks React's Power

Writing pure components isn't just a style preference - it's what makes React's advanced features possible. Every major React optimization depends on component purity.

## Benefits of Pure Components

### 1. Safe to Cache (React.memo)

```tsx
// Pure component can be safely memoized
const ExpensiveChart = React.memo(function ExpensiveChart({
  data,
}: {
  data: ChartData;
}) {
  // Expensive calculations here
  return <svg>...</svg>;
});

function Dashboard({ data, theme }: Props) {
  return (
    <div className={theme}>
      {/* Only re-renders when `data` changes */}
      <ExpensiveChart data={data} />
    </div>
  );
}
```

### 2. Server-Side Rendering

```tsx
// Pure components render the same on server and client
function ProductCard({ product }: { product: Product }) {
  // No external dependencies = same HTML everywhere
  return (
    <div className="product">
      <h2>{product.name}</h2>
      <p>{product.description}</p>
      <span>${product.price}</span>
    </div>
  );
}

// Works perfectly with SSR, SSG, and RSC
```

### 3. Concurrent Rendering

```tsx
// Pure components can be safely interrupted and resumed
function SearchResults({ query }: { query: string }) {
  const results = search(query);  // Pure computation

  return (
    <ul>
      {results.map(result => (
        <li key={result.id}>{result.title}</li>
      ))}
    </ul>
  );
}

// React can:
// - Pause rendering this component
// - Handle a more urgent update
// - Resume from where it left off
// - Discard if query changed
```

### 4. Development Reliability

```tsx
// Pure components work the same in:
// - Development mode
// - Production mode
// - StrictMode (double render)
// - Future React versions

function Counter({ count }: { count: number }) {
  // Always returns the same JSX for same count
  return <span>{count}</span>;
}
```

### 5. Testing Simplicity

```tsx
// Pure components are trivial to test
function Greeting({ name, isLoggedIn }: Props) {
  if (!isLoggedIn) {
    return <span>Please log in</span>;
  }
  return <span>Hello, {name}!</span>;
}

// Test is simple - no mocking needed
test('shows greeting for logged in user', () => {
  const { getByText } = render(
    <Greeting name="Alice" isLoggedIn={true} />
  );
  expect(getByText('Hello, Alice!')).toBeInTheDocument();
});
```

## What Impurity Breaks

```tsx
// IMPURE: External dependency makes all optimizations unsafe
let renderCount = 0;

function ImpureComponent({ name }: { name: string }) {
  renderCount++;  // Side effect during render

  return <div>Hello {name} (render #{renderCount})</div>;
}

// React.memo can't safely skip renders
// SSR produces different HTML than client
// Concurrent rendering causes bugs
// StrictMode shows wrong numbers
// Tests are flaky
```

## The Performance Guarantee

```tsx
// Because components are pure, React can make guarantees:

function App({ users }: { users: User[] }) {
  return (
    <div>
      {users.map(user => (
        // React KNOWS: if user reference is the same,
        // UserCard will return the same JSX
        <UserCard key={user.id} user={user} />
      ))}
    </div>
  );
}

// This enables:
// - Skipping renders for unchanged items
// - Reusing fibers from previous renders
// - Batching updates efficiently
// - Streaming SSR
```

## React's Contract

React promises:
1. Call your function when inputs change
2. Use the returned JSX to update the DOM
3. Optimize by skipping unnecessary work

You promise:
1. Same inputs → same output
2. No mutations of external data during render
3. No side effects during render

## Key Principle

Purity isn't a restriction - it's a superpower. By keeping components pure, you get caching, concurrent rendering, server rendering, and future React features for free.
