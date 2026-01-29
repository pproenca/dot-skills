---
title: Pass handlers, don't call them
impact: HIGH
impactDescription: Event handlers should be passed as references, not called inline with parentheses
tags: [event, handlers, callbacks, onclick, common-mistakes]
---

# Pass Handlers, Don't Call Them

When setting event handlers, pass the function reference. Don't call the function inline - that executes it during render instead of on the event.

## Incorrect: Calling the Handler

```tsx
// Problem: Calling the function during render
function Button() {
  function handleClick() {
    console.log('Clicked!');
  }

  return (
    <button onClick={handleClick()}>  {/* ❌ Called immediately! */}
      Click me
    </button>
  );
}
// "Clicked!" logs on every render, not on click
```

## Correct: Passing the Handler

```tsx
// Solution: Passing the function reference
function Button() {
  function handleClick() {
    console.log('Clicked!');
  }

  return (
    <button onClick={handleClick}>  {/* ✅ Reference, not call */}
      Click me
    </button>
  );
}
// "Clicked!" logs only when button is clicked
```

## With Arguments: Use Arrow Function

```tsx
// Solution: Arrow function wrapper for arguments
function TodoList({ todos, onDelete }: Props) {
  return (
    <ul>
      {todos.map(todo => (
        <li key={todo.id}>
          {todo.text}
          {/* Arrow function creates new function that calls onDelete with id */}
          <button onClick={() => onDelete(todo.id)}>
            Delete
          </button>
        </li>
      ))}
    </ul>
  );
}
```

## Incorrect: Calling with Arguments

```tsx
// Problem: This calls onDelete during render!
<button onClick={onDelete(todo.id)}>Delete</button>

// onDelete(todo.id) returns undefined (or whatever onDelete returns)
// Then onClick={undefined}, which does nothing on click
// AND onDelete runs during every render!
```

## Event Object Access

```tsx
// React passes the event object automatically
function Input() {
  function handleChange(event: ChangeEvent<HTMLInputElement>) {
    console.log(event.target.value);
  }

  return <input onChange={handleChange} />;
}

// With arrow function, you can access event and add args
function Form({ onSubmit }: { onSubmit: (value: string) => void }) {
  const [value, setValue] = useState('');

  return (
    <form onSubmit={(e) => {
      e.preventDefault();  // Access event
      onSubmit(value);     // Pass custom arg
    }}>
      <input value={value} onChange={e => setValue(e.target.value)} />
      <button type="submit">Submit</button>
    </form>
  );
}
```

## Handler Naming Convention

```tsx
function MyComponent() {
  // Handlers defined in component use "handle" prefix
  function handleClick() { /* ... */ }
  function handleSubmit() { /* ... */ }
  function handleChange() { /* ... */ }

  return (
    <div>
      <button onClick={handleClick}>Click</button>
      <form onSubmit={handleSubmit}>...</form>
      <input onChange={handleChange} />
    </div>
  );
}

// Props that accept handlers use "on" prefix
interface Props {
  onClick: () => void;
  onSubmit: (data: FormData) => void;
  onChange: (value: string) => void;
}
```

## Common Patterns

```tsx
// Direct reference (no arguments needed)
<button onClick={handleClick}>

// Arrow wrapper (need to pass arguments)
<button onClick={() => handleDelete(id)}>

// Arrow wrapper (need event + arguments)
<button onClick={(e) => handleClick(e, id)}>

// Inline simple logic
<button onClick={() => setCount(c => c + 1)}>
```

## Key Principle

`onClick={fn}` passes `fn` to be called later. `onClick={fn()}` calls `fn` now and passes its return value. The first is almost always what you want.
