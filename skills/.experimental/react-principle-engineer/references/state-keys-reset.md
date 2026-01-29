---
title: Use keys to reset component state
impact: MEDIUM
impactDescription: Changing a component's key tells React to destroy and recreate it, resetting all internal state
tags: [state, keys, reset, identity, remounting]
---

# Use Keys to Reset Component State

When you give a component a different `key`, React treats it as a completely different component. It unmounts the old one and mounts a new one, resetting all state.

## Why This Matters

Keys for reset:
- Provide explicit control over component identity
- Reset form state when switching between items
- Clear stale state when data source changes
- Avoid complex "reset" logic in useEffect

## The Problem

```tsx
// Without key: Chat keeps old state when switching contacts
function Chat({ contact }: { contact: Contact }) {
  const [text, setText] = useState('');

  return (
    <div>
      <h2>Chat with {contact.name}</h2>
      <input value={text} onChange={e => setText(e.target.value)} />
    </div>
  );
}

function App() {
  const [selectedContact, setSelectedContact] = useState(contacts[0]);

  return (
    <div>
      <ContactList
        contacts={contacts}
        onSelect={setSelectedContact}
      />
      {/* BUG: Message draft carries over between contacts! */}
      <Chat contact={selectedContact} />
    </div>
  );
}
```

**Correct (the solution):** Key by Identity

```tsx
function App() {
  const [selectedContact, setSelectedContact] = useState(contacts[0]);

  return (
    <div>
      <ContactList
        contacts={contacts}
        onSelect={setSelectedContact}
      />
      {/* Key change = new Chat instance with fresh state */}
      <Chat key={selectedContact.id} contact={selectedContact} />
    </div>
  );
}
```

## How Keys Work

```tsx
// Same key = same component instance, state preserved
<Chat key="alice" contact={alice} />  // First render
<Chat key="alice" contact={alice} />  // Same key, state preserved

// Different key = different component instance, state reset
<Chat key="alice" contact={alice} />  // Has state
<Chat key="bob" contact={bob} />      // Fresh state, old state gone
```

## Form Reset Pattern

```tsx
function EditContact({ contact }: { contact: Contact }) {
  // Local form state
  const [formData, setFormData] = useState({
    name: contact.name,
    email: contact.email,
  });

  // Without key on parent: formData is stale when contact changes
  // With key={contact.id} on parent: formData is fresh

  return (
    <form>
      <input
        value={formData.name}
        onChange={e => setFormData({ ...formData, name: e.target.value })}
      />
      <input
        value={formData.email}
        onChange={e => setFormData({ ...formData, email: e.target.value })}
      />
    </form>
  );
}

function App() {
  const [editingId, setEditingId] = useState<string | null>(null);
  const contact = contacts.find(c => c.id === editingId);

  return (
    <div>
      <ContactList onEdit={setEditingId} />
      {contact && (
        // Key ensures form resets when switching contacts
        <EditContact key={contact.id} contact={contact} />
      )}
    </div>
  );
}
```

## Alternative: Effect-Based Reset (Avoid If Possible)

```tsx
// AVOID: Using effect to reset state
function EditContact({ contact }: { contact: Contact }) {
  const [formData, setFormData] = useState({
    name: contact.name,
    email: contact.email,
  });

  // This works but is more complex and error-prone
  useEffect(() => {
    setFormData({
      name: contact.name,
      email: contact.email,
    });
  }, [contact.id]);  // Reset when contact changes

  return <form>...</form>;
}

// PREFER: Key-based reset (cleaner, no effect needed)
<EditContact key={contact.id} contact={contact} />
```

## Same Position, Different Components

```tsx
function App() {
  const [isPaused, setIsPaused] = useState(false);

  return (
    <div>
      {isPaused ? (
        <p>See you later!</p>
      ) : (
        // Counter at this position keeps state when isPaused toggles
        // because React sees "a component at position 1"
        <Counter />
      )}
    </div>
  );
}

// To reset Counter when re-appearing, use key:
{isPaused ? (
  <p>See you later!</p>
) : (
  <Counter key={String(isPaused)} />
)}
```

## Preserving State with Consistent Keys

```tsx
// Keys also PRESERVE state when reordering
function Tabs({ tabs, activeId }: Props) {
  return (
    <div>
      {tabs.map(tab => (
        // Same key = same component instance, even if position changes
        <TabContent
          key={tab.id}  // Preserves state across reorders
          tab={tab}
          isActive={tab.id === activeId}
        />
      ))}
    </div>
  );
}
```

## Key Principle

Think of `key` as telling React "this is THE component for this specific thing." When the key changes, it's a different thing entirely, so React starts fresh. Use this to reset state intentionally rather than writing complex reset logic.
