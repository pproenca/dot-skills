---
title: Group related state variables together
impact: HIGH
impactDescription: Related state that changes together should be unified to prevent sync bugs and simplify updates
tags: [state, structure, organization, grouping]
---

# Group Related State Variables Together

When two or more state variables always change at the same time, consider combining them into a single state variable. This prevents them from getting out of sync.

## Why This Matters

Grouped state:
- Can't become inconsistent (one updated, other forgotten)
- Reduces the number of state setters to call
- Makes the relationship between values explicit
- Simplifies event handler logic

**Incorrect (anti-pattern):**

```tsx
// Problem: Separate state for values that always change together
function MovingDot() {
  const [x, setX] = useState(0);
  const [y, setY] = useState(0);

  function handlePointerMove(e: PointerEvent) {
    // Must remember to update both!
    setX(e.clientX);
    setY(e.clientY);
    // Easy to forget one, or update them at different times
  }

  return (
    <div
      onPointerMove={handlePointerMove}
      style={{ width: '100vw', height: '100vh' }}
    >
      <div
        style={{
          position: 'absolute',
          left: x,
          top: y,
          width: 20,
          height: 20,
          borderRadius: '50%',
          backgroundColor: 'red',
        }}
      />
    </div>
  );
}
```

**Correct (recommended):**

```tsx
// Solution: Single state for values that change together
function MovingDot() {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  function handlePointerMove(e: PointerEvent) {
    // One update, always in sync
    setPosition({ x: e.clientX, y: e.clientY });
  }

  return (
    <div
      onPointerMove={handlePointerMove}
      style={{ width: '100vw', height: '100vh' }}
    >
      <div
        style={{
          position: 'absolute',
          left: position.x,
          top: position.y,
          width: 20,
          height: 20,
          borderRadius: '50%',
          backgroundColor: 'red',
        }}
      />
    </div>
  );
}
```

**Incorrect (anti-pattern):**

```tsx
// Problem: Form field state as separate variables
function ProfileForm() {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');

  function handleReset() {
    // Must remember ALL fields
    setFirstName('');
    setLastName('');
    setEmail('');
    setPhone('');
    // Easy to forget one when adding new fields
  }

  // ... lots of individual handlers
}
```

**Correct (recommended):**

```tsx
// Solution: Form state as a single object
interface FormData {
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
}

function ProfileForm() {
  const [formData, setFormData] = useState<FormData>({
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
  });

  function handleChange(field: keyof FormData, value: string) {
    setFormData(prev => ({ ...prev, [field]: value }));
  }

  function handleReset() {
    // One reset handles everything
    setFormData({
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
    });
  }

  return (
    <form>
      <input
        value={formData.firstName}
        onChange={e => handleChange('firstName', e.target.value)}
      />
      {/* Other fields */}
    </form>
  );
}
```

## When to Keep Separate

```tsx
// FINE: These change independently at different times
function Page() {
  const [isLoading, setIsLoading] = useState(false);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  // isLoading changes during fetch
  // selectedId changes on item click
  // searchQuery changes on typing
  // They're genuinely independent
}
```

## Caveat: Updating Object State

```tsx
// When state is an object, remember to spread existing properties
function Form() {
  const [person, setPerson] = useState({
    firstName: 'Taylor',
    lastName: 'Swift',
    email: 'taylor@example.com',
  });

  function handleFirstNameChange(e: ChangeEvent<HTMLInputElement>) {
    // WRONG: loses lastName and email
    // setPerson({ firstName: e.target.value });

    // CORRECT: spread existing, then override
    setPerson({
      ...person,
      firstName: e.target.value,
    });
  }
}
```

## Signs You Should Group State

- Two or more `setState` calls always appear together
- Forgetting one update causes bugs
- The values represent a single concept (position, dimensions, person)
- You need to reset all values at once

## Key Principle

If you always update state A when you update state B, they should probably be one piece of state. The code structure should make the relationship obvious and the update atomic.
