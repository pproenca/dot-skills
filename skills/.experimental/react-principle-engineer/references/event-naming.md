---
title: Follow event handler naming conventions
impact: LOW
impactDescription: Use "handle" prefix for handlers, "on" prefix for props; be descriptive about what event triggers the handler
tags: [event, naming, conventions, handlers, props]
---

# Follow Event Handler Naming Conventions

Use consistent naming for event handlers: `handleX` for the function, `onX` for the prop. This makes code predictable and scannable.

## The Convention

```tsx
// HANDLERS: "handle" + what happened
function handleClick() { }
function handleSubmit() { }
function handleChange() { }
function handleMouseEnter() { }

// PROPS: "on" + what happened
interface ButtonProps {
  onClick: () => void;
  onHover?: () => void;
}
```

## Complete Example

```tsx
// Parent defines handlers
function App() {
  function handleUserSelect(userId: string) {
    console.log('Selected:', userId);
  }

  function handleUserDelete(userId: string) {
    console.log('Deleted:', userId);
  }

  return (
    <UserList
      onSelect={handleUserSelect}
      onDelete={handleUserDelete}
    />
  );
}

// Child defines props with "on" prefix
interface UserListProps {
  onSelect: (userId: string) => void;
  onDelete: (userId: string) => void;
}

function UserList({ onSelect, onDelete }: UserListProps) {
  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>
          <button onClick={() => onSelect(user.id)}>Select</button>
          <button onClick={() => onDelete(user.id)}>Delete</button>
        </li>
      ))}
    </ul>
  );
}
```

## Be Descriptive

```tsx
// Problem: Vague names
function handle() { }  // Handle what?
function onClick() { }  // This is a prop name, not handler name

// Solution: Descriptive names
function handleFormSubmit() { }
function handleEmailChange() { }
function handleAddToCartClick() { }
function handleModalClose() { }
```

## Internal vs Prop Handlers

```tsx
function SearchBox({ onSearch }: { onSearch: (query: string) => void }) {
  const [query, setQuery] = useState('');

  // Internal handler (handles local concerns)
  function handleInputChange(e: ChangeEvent<HTMLInputElement>) {
    setQuery(e.target.value);
  }

  // Handler that calls prop (bridges to parent)
  function handleSearchClick() {
    onSearch(query);  // Call parent's handler
  }

  return (
    <div>
      <input value={query} onChange={handleInputChange} />
      <button onClick={handleSearchClick}>Search</button>
    </div>
  );
}
```

## DOM Events vs Custom Events

```tsx
// DOM events: use standard names
onClick
onChange
onSubmit
onMouseEnter
onKeyDown

// Custom events: describe the domain action
onUserSelect
onItemDelete
onFilterChange
onPageChange
onSearch
```

## Async Handlers

```tsx
// Async handlers follow same convention
async function handleSubmit(e: FormEvent) {
  e.preventDefault();
  await submitForm(data);
}

// Can indicate async in name if helpful
async function handleAsyncSave() {
  await saveData();
}
```

## Key Principle

`handle` = "this function handles the event" (used where you define it). `on` = "call this when event happens" (used in props/attributes). Consistent naming makes code self-documenting.
