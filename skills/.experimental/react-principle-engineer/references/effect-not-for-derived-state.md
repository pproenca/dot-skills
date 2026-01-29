---
title: Don't use effects for derived state
impact: HIGH
impactDescription: Values that can be calculated from props or state should be computed during render, not in effects
tags: [effect, derived, state, calculation, render]
---

# Don't Use Effects for Derived State

If you can calculate something from existing props or state, do it during render. Effects are for synchronizing with external systems, not for transforming data.

## Why This Matters

Calculating in render:
- Avoids unnecessary re-renders (effect → setState → render)
- Keeps state minimal
- Makes data flow obvious
- Is simpler and faster

## Incorrect: Effect for Derived Value

```tsx
// Problem: Using effect to "sync" derived state
function TodoList({ todos }: { todos: Todo[] }) {
  const [filteredTodos, setFilteredTodos] = useState<Todo[]>([]);
  const [filter, setFilter] = useState('all');

  // WRONG: This is just a transformation, not external sync
  useEffect(() => {
    if (filter === 'all') {
      setFilteredTodos(todos);
    } else if (filter === 'active') {
      setFilteredTodos(todos.filter(t => !t.done));
    } else {
      setFilteredTodos(todos.filter(t => t.done));
    }
  }, [todos, filter]);

  // Problems:
  // 1. Extra render (first without filter, then with)
  // 2. Flicker on filter change
  // 3. Unnecessary complexity
}
```

## Correct: Calculate During Render

```tsx
// Solution: Calculate during render
function TodoList({ todos }: { todos: Todo[] }) {
  const [filter, setFilter] = useState('all');

  // Derived value - calculated every render
  const filteredTodos = todos.filter(todo => {
    if (filter === 'all') return true;
    if (filter === 'active') return !todo.done;
    return todo.done;
  });

  // No state, no effect, no extra render
  return <List items={filteredTodos} />;
}
```

## Incorrect: Effect Chain for Transformations

```tsx
// Problem: Chain of effects to transform data
function DataProcessor({ rawData }: { rawData: RawData }) {
  const [parsed, setParsed] = useState(null);
  const [filtered, setFiltered] = useState(null);
  const [sorted, setSorted] = useState(null);

  useEffect(() => {
    setParsed(parseData(rawData));
  }, [rawData]);

  useEffect(() => {
    if (parsed) {
      setFiltered(filterData(parsed));
    }
  }, [parsed]);

  useEffect(() => {
    if (filtered) {
      setSorted(sortData(filtered));
    }
  }, [filtered]);

  // Three effects, three state updates, four renders!
}
```

## Correct: Single Calculation

```tsx
// Solution: One calculation during render
function DataProcessor({ rawData }: { rawData: RawData }) {
  const processed = useMemo(() => {
    const parsed = parseData(rawData);
    const filtered = filterData(parsed);
    return sortData(filtered);
  }, [rawData]);

  // One calculation, one value, one render
  return <Display data={processed} />;
}
```

## When useMemo Is Needed

```tsx
// If calculation is expensive, memoize it
function ExpensiveList({ items, filter }: Props) {
  // Only recalculates when items or filter changes
  const filteredItems = useMemo(
    () => items.filter(item => expensiveCheck(item, filter)),
    [items, filter]
  );

  return <List items={filteredItems} />;
}

// But don't memoize everything!
// Simple calculations are fine without memo
function SimpleList({ items }: Props) {
  const count = items.length;  // No memo needed
  const hasItems = items.length > 0;  // No memo needed

  return (
    <div>
      {hasItems ? <List items={items} /> : <Empty />}
      <span>{count} items</span>
    </div>
  );
}
```

## The Anti-Pattern: State Sync

```tsx
// Problem: Syncing state with props via effect
function Form({ initialName }: { initialName: string }) {
  const [name, setName] = useState(initialName);

  // WRONG: Trying to "sync" when prop changes
  useEffect(() => {
    setName(initialName);
  }, [initialName]);
}

// This pattern indicates confusion about state ownership
// Either:
// 1. Use prop directly (controlled)
// 2. Accept that state is independent (uncontrolled)
// 3. Use key to reset: <Form key={id} initialName={name} />
```

## Signs You're Misusing Effects

```tsx
// RED FLAGS:

// 1. Effect that only sets state based on props/state
useEffect(() => {
  setDerived(calculate(prop));
}, [prop]);

// 2. Effect that transforms data
useEffect(() => {
  setFiltered(data.filter(predicate));
}, [data]);

// 3. Effect that combines state
useEffect(() => {
  setFullName(firstName + ' ' + lastName);
}, [firstName, lastName]);

// All of these should be render-time calculations!
```

## Key Principle

Effects are for synchronizing with things OUTSIDE React (network, DOM, timers). Transforming data is INSIDE React - do it during render.
