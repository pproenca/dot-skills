---
title: Maintain a single source of truth
impact: HIGH
impactDescription: Each piece of state should have exactly one owner component that controls it
tags: [share, sharing, source-of-truth, ownership, data-flow]
---

# Maintain a Single Source of Truth

For any piece of state, there should be one specific component that "owns" it. Other components may read it (via props) or request changes (via callbacks), but only the owner can modify it.

## Why This Matters

Single source of truth:
- Prevents conflicting updates
- Makes debugging straightforward
- Creates clear data flow
- Avoids sync issues between copies

## Incorrect: Multiple Sources

```tsx
// Problem: Both parent and child "own" the email
function Parent() {
  const [email, setEmail] = useState('');

  return (
    <div>
      <p>Parent email: {email}</p>
      {/* Child has its own copy */}
      <EmailInput initialEmail={email} />
    </div>
  );
}

function EmailInput({ initialEmail }: { initialEmail: string }) {
  // Child has its own "version" of email
  const [email, setEmail] = useState(initialEmail);

  // Now there are TWO email values that can diverge!

  return (
    <input value={email} onChange={e => setEmail(e.target.value)} />
  );
}
```

## Correct: Single Owner

```tsx
// Solution: Parent is the single source of truth
function Parent() {
  const [email, setEmail] = useState('');

  return (
    <div>
      <p>Email: {email}</p>
      {/* Child reads and requests changes, doesn't own */}
      <EmailInput email={email} onChange={setEmail} />
    </div>
  );
}

function EmailInput({
  email,
  onChange,
}: {
  email: string;
  onChange: (email: string) => void;
}) {
  // No local state - just uses props
  return (
    <input value={email} onChange={e => onChange(e.target.value)} />
  );
}
```

## Identifying the Owner

Ask: "Which component should be the source of truth for this data?"

```tsx
// User data: Probably owned by App or a UserProvider
// Form input values: Owned by the form component
// Modal open/closed: Owned by component that opens it
// Selected item: Owned by component that manages the list

// CORRECT: Form owns its field values
function ProfileForm() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    bio: '',
  });

  function handleChange(field: string, value: string) {
    setFormData(prev => ({ ...prev, [field]: value }));
  }

  return (
    <form>
      <TextField
        label="Name"
        value={formData.name}
        onChange={v => handleChange('name', v)}
      />
      <TextField
        label="Email"
        value={formData.email}
        onChange={v => handleChange('email', v)}
      />
      <TextArea
        label="Bio"
        value={formData.bio}
        onChange={v => handleChange('bio', v)}
      />
    </form>
  );
}
```

## Props Down, Events Up

```tsx
// Data flows DOWN via props
// Change requests flow UP via callbacks

function ShoppingCart() {
  const [items, setItems] = useState<CartItem[]>([]);

  function updateQuantity(itemId: string, quantity: number) {
    setItems(prev =>
      prev.map(item =>
        item.id === itemId ? { ...item, quantity } : item
      )
    );
  }

  function removeItem(itemId: string) {
    setItems(prev => prev.filter(item => item.id !== itemId));
  }

  return (
    <div>
      {items.map(item => (
        <CartItemRow
          key={item.id}
          item={item}  // Data down
          onQuantityChange={q => updateQuantity(item.id, q)}  // Events up
          onRemove={() => removeItem(item.id)}  // Events up
        />
      ))}
    </div>
  );
}

function CartItemRow({
  item,
  onQuantityChange,
  onRemove,
}: CartItemRowProps) {
  // No local state for item data - owned by parent
  return (
    <div>
      <span>{item.name}</span>
      <input
        type="number"
        value={item.quantity}
        onChange={e => onQuantityChange(Number(e.target.value))}
      />
      <button onClick={onRemove}>Remove</button>
    </div>
  );
}
```

## Derived Data Is Not a Source

```tsx
// Solution: One source, derived values
function TodoList() {
  // Single source of truth: the todos array
  const [todos, setTodos] = useState<Todo[]>([]);

  // Derived values - NOT sources of truth
  const total = todos.length;
  const completed = todos.filter(t => t.done).length;
  const remaining = total - completed;

  // The ONLY way to change these values is by modifying todos
  // They can never get out of sync
}
```

## Anti-Pattern: Syncing State

```tsx
// Problem: Two sources that try to stay in sync
function Bad() {
  const [items, setItems] = useState<Item[]>([]);
  const [selectedItem, setSelectedItem] = useState<Item | null>(null);

  // Trying to keep selectedItem in sync when items change
  useEffect(() => {
    if (selectedItem && !items.find(i => i.id === selectedItem.id)) {
      setSelectedItem(null);
    }
  }, [items, selectedItem]);

  // Complex, error-prone...
}

// Solution: One source, derive the other
function Good() {
  const [items, setItems] = useState<Item[]>([]);
  const [selectedId, setSelectedId] = useState<string | null>(null);

  // Derived - automatically correct
  const selectedItem = items.find(i => i.id === selectedId) ?? null;

  // No sync needed!
}
```

## Key Principle

Draw your state on a diagram. Each piece of data should have exactly one box (component) that owns it. If data appears in multiple boxes, you need to lift it up until there's one owner.
