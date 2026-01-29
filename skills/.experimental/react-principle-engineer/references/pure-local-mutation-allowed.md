---
title: Local mutation during render is fine
impact: MEDIUM
impactDescription: Variables created during render can be freely mutated since they don't affect other components
tags: [pure, mutations, performance, patterns]
---

# Local Mutation During Render Is Fine

You can freely mutate variables and objects that you create during the same render. This is called "local mutation" and is completely safe because no other code can observe these values until rendering completes.

## Why This Matters

Understanding local mutation:
- Lets you write performant code without excessive copying
- Avoids unnecessary verbosity
- Makes building arrays and objects natural
- Distinguishes harmful mutations from harmless ones

**Correct (recommended):**

```tsx
// Solution: Building an array during render with mutation
function TeaGathering() {
  const cups = [];  // Created during this render

  // Mutating the local array is fine
  for (let i = 1; i <= 12; i++) {
    cups.push(<Cup key={i} guestNumber={i} />);
  }

  return <div>{cups}</div>;
}
```

## Also Correct

```tsx
// Solution: Building an object during render
function UserProfile({ firstName, lastName, email }: UserProps) {
  // Created fresh each render, mutation is fine
  const displayData = {
    fullName: '',
    initials: '',
  };

  displayData.fullName = `${firstName} ${lastName}`;
  displayData.initials = firstName[0] + lastName[0];

  return (
    <div>
      <h1>{displayData.fullName}</h1>
      <span className="initials">{displayData.initials}</span>
    </div>
  );
}
```

**Incorrect (anti-pattern):**

```tsx
// Problem: Mutating an object that existed before render
const sharedConfig = { theme: 'light', fontSize: 16 };

function Settings({ userPreference }: { userPreference: string }) {
  // WRONG - this object existed before render
  sharedConfig.theme = userPreference;

  return <div>Theme: {sharedConfig.theme}</div>;
}
```

## The Distinction

```tsx
// The key question: Was this object created DURING this render?

function Example({ items }: { items: Item[] }) {
  // BAD: items is a prop - existed before render
  items.push({ id: 'new' });  // WRONG!

  // GOOD: newItems is created during this render
  const newItems = [...items, { id: 'new' }];  // Fine

  // GOOD: result is created during this render
  const result = [];
  for (const item of items) {
    result.push(processItem(item));  // Fine to mutate result
  }

  return <ItemList items={newItems} />;
}
```

## Performance Benefit

```tsx
// Local mutation can be more performant than pure approaches
function ProcessedList({ data }: { data: number[] }) {
  // This is fine and efficient
  const processed = [];
  for (let i = 0; i < data.length; i++) {
    if (data[i] > 0) {
      processed.push(data[i] * 2);
    }
  }

  // Equivalent functional approach (also fine, slightly more allocation)
  const processedFunctional = data
    .filter(n => n > 0)
    .map(n => n * 2);

  return <Numbers values={processed} />;
}
```

## Key Principle

The rule is about when the object was created, not about mutation itself. Objects created during render are your "local variables" - mutate them freely. Objects passed in (props) or existing before render are "shared state" - never mutate those.
