---
title: Components render independently
impact: MEDIUM
impactDescription: Each component should calculate its output independently without relying on or coordinating with other components' render order
tags: [pure, rendering, independence, isolation]
---

# Components Render Independently

Each component should "think for itself" and not depend on when or how other components render. React may render components in any order, at any time, and potentially in parallel.

## Why This Matters

React's rendering model assumes independence:
- Concurrent features can pause and resume rendering
- React may render siblings in any order
- Parent and child may render at different times
- Future React versions may parallelize rendering

**Incorrect (anti-pattern):**

```tsx
// Problem: Components coordinating through shared mutable state
let sharedCounter = 0;

function ComponentA() {
  sharedCounter++;  // Expects to run first
  return <div>A: {sharedCounter}</div>;
}

function ComponentB() {
  sharedCounter++;  // Expects A already ran
  return <div>B: {sharedCounter}</div>;
}

function App() {
  return (
    <div>
      <ComponentA />
      <ComponentB />
    </div>
  );
  // Bug: Result depends on render order!
  // With StrictMode or concurrent rendering, results are unpredictable
}
```

**Correct (recommended):**

```tsx
// Solution: Each component receives what it needs via props
function ComponentA({ counter }: { counter: number }) {
  return <div>A: {counter}</div>;
}

function ComponentB({ counter }: { counter: number }) {
  return <div>B: {counter}</div>;
}

function App() {
  const [counter, setCounter] = useState(0);

  return (
    <div>
      <ComponentA counter={counter} />
      <ComponentB counter={counter + 1} />
      <button onClick={() => setCounter(c => c + 2)}>
        Increment Both
      </button>
    </div>
  );
  // Works correctly regardless of render order
}
```

**Incorrect (anti-pattern):**

```tsx
// Problem: Relying on document state set by sibling
function Header() {
  // Sets something a sibling will read
  document.title = 'My App';
  return <header>My App</header>;
}

function MetaReader() {
  // Assumes Header already ran and set the title
  const title = document.title;
  return <div>Title is: {title}</div>;
}
```

**Correct (recommended):**

```tsx
// Solution: Share data through React, not DOM
function App() {
  const title = 'My App';

  return (
    <>
      <Header title={title} />
      <MetaReader title={title} />
    </>
  );
}

function Header({ title }: { title: string }) {
  useEffect(() => {
    document.title = title;  // Effect for DOM side effect
  }, [title]);

  return <header>{title}</header>;
}

function MetaReader({ title }: { title: string }) {
  return <div>Title is: {title}</div>;
}
```

## Analogy: Components as Exam Takers

Think of rendering like a school exam:
- Each student (component) works independently
- Students can't look at each other's answers
- The order students finish doesn't affect their answers
- Each student has their own copy of the questions (props)

## Correct Coordination Pattern

```tsx
// Solution: Coordinate through shared parent state
function Panel({ isActive, onActivate, children }) {
  return (
    <section>
      {isActive ? children : <button onClick={onActivate}>Show</button>}
    </section>
  );
}

function Accordion() {
  // Parent owns the coordination state
  const [activeIndex, setActiveIndex] = useState(0);

  return (
    <>
      <Panel
        isActive={activeIndex === 0}
        onActivate={() => setActiveIndex(0)}
      >
        First panel content
      </Panel>
      <Panel
        isActive={activeIndex === 1}
        onActivate={() => setActiveIndex(1)}
      >
        Second panel content
      </Panel>
    </>
  );
  // Panels don't know about each other - parent coordinates
}
```

## Key Principle

If component B's output depends on component A having already rendered, you have a design problem. Move the shared concern up to a common parent that can pass the data down to both.
