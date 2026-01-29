---
title: Store IDs instead of duplicating objects
impact: HIGH
impactDescription: Duplicated objects in state can become out of sync when one copy is updated but others are not
tags: [state, structure, normalization, ids, duplication]
---

# Store IDs Instead of Duplicating Objects

When you need to reference an item from a list, store its ID rather than the entire object. This prevents the copies from getting out of sync.

## Why This Matters

Duplicated objects:
- Require updating multiple places when data changes
- Get out of sync causing UI inconsistencies
- Make it unclear which is the "source of truth"
- Waste memory storing the same data multiple times

**Incorrect (anti-pattern):**

```tsx
// Problem: Storing the entire selected item as a copy
interface Item {
  id: number;
  title: string;
}

function Menu() {
  const [items, setItems] = useState<Item[]>([
    { id: 0, title: 'Pretzels' },
    { id: 1, title: 'Seaweed' },
    { id: 2, title: 'Granola' },
  ]);

  // This is a COPY of an object from items
  const [selectedItem, setSelectedItem] = useState<Item>(items[0]);

  function handleItemChange(id: number, newTitle: string) {
    setItems(items.map(item =>
      item.id === id ? { ...item, title: newTitle } : item
    ));
    // BUG: selectedItem is not updated!
    // If you edit the selected item, the selection shows old data
  }

  return (
    <>
      <ul>
        {items.map(item => (
          <li key={item.id}>
            <input
              value={item.title}
              onChange={e => handleItemChange(item.id, e.target.value)}
            />
            <button onClick={() => setSelectedItem(item)}>
              Select
            </button>
          </li>
        ))}
      </ul>
      <p>You selected: {selectedItem.title}</p>
      {/* This shows stale data after editing! */}
    </>
  );
}
```

**Correct (recommended):**

```tsx
// Solution: Store only the ID, derive the object when needed
function Menu() {
  const [items, setItems] = useState<Item[]>([
    { id: 0, title: 'Pretzels' },
    { id: 1, title: 'Seaweed' },
    { id: 2, title: 'Granola' },
  ]);

  // Store just the ID
  const [selectedId, setSelectedId] = useState<number>(0);

  // Derive the selected item from the source of truth
  const selectedItem = items.find(item => item.id === selectedId);

  function handleItemChange(id: number, newTitle: string) {
    setItems(items.map(item =>
      item.id === id ? { ...item, title: newTitle } : item
    ));
    // selectedItem automatically updates because it's derived!
  }

  return (
    <>
      <ul>
        {items.map(item => (
          <li key={item.id}>
            <input
              value={item.title}
              onChange={e => handleItemChange(item.id, e.target.value)}
            />
            <button onClick={() => setSelectedId(item.id)}>
              Select
            </button>
          </li>
        ))}
      </ul>
      <p>You selected: {selectedItem?.title}</p>
      {/* Always shows current data */}
    </>
  );
}
```

**Incorrect (anti-pattern):**

```tsx
// Problem: Storing highlighted letter as object
function Mailbox() {
  const [letters, setLetters] = useState<Letter[]>(initialLetters);
  const [highlightedLetter, setHighlightedLetter] = useState<Letter | null>(null);

  function handleStar(letterId: string) {
    setLetters(letters.map(letter =>
      letter.id === letterId
        ? { ...letter, isStarred: !letter.isStarred }
        : letter
    ));
    // BUG: If highlighted letter was starred, highlight shows old state
  }

  return (
    <ul>
      {letters.map(letter => (
        <li
          key={letter.id}
          className={letter === highlightedLetter ? 'highlighted' : ''}
          // BUG: Object identity comparison fails after update!
          onMouseEnter={() => setHighlightedLetter(letter)}
        >
          {letter.subject}
          <button onClick={() => handleStar(letter.id)}>
            {letter.isStarred ? 'Unstar' : 'Star'}
          </button>
        </li>
      ))}
    </ul>
  );
}
```

**Correct (recommended):**

```tsx
// Solution: Store highlighted ID, compare by ID
function Mailbox() {
  const [letters, setLetters] = useState<Letter[]>(initialLetters);
  const [highlightedId, setHighlightedId] = useState<string | null>(null);

  function handleStar(letterId: string) {
    setLetters(letters.map(letter =>
      letter.id === letterId
        ? { ...letter, isStarred: !letter.isStarred }
        : letter
    ));
    // Highlight works correctly because we compare by ID
  }

  return (
    <ul>
      {letters.map(letter => (
        <li
          key={letter.id}
          className={letter.id === highlightedId ? 'highlighted' : ''}
          onMouseEnter={() => setHighlightedId(letter.id)}
        >
          {letter.subject}
          <button onClick={() => handleStar(letter.id)}>
            {letter.isStarred ? 'Unstar' : 'Star'}
          </button>
        </li>
      ))}
    </ul>
  );
}
```

## Multiple Selections

```tsx
// Solution: Set of IDs for multiple selection
function MultiSelect() {
  const [items, setItems] = useState<Item[]>(initialItems);
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());

  function toggleSelection(id: string) {
    const next = new Set(selectedIds);
    if (next.has(id)) {
      next.delete(id);
    } else {
      next.add(id);
    }
    setSelectedIds(next);
  }

  // Derive selected items when needed
  const selectedItems = items.filter(item => selectedIds.has(item.id));
  const selectedCount = selectedIds.size;

  return (
    <>
      <p>{selectedCount} items selected</p>
      {items.map(item => (
        <Checkbox
          key={item.id}
          checked={selectedIds.has(item.id)}
          onChange={() => toggleSelection(item.id)}
          label={item.name}
        />
      ))}
    </>
  );
}
```

## Key Principle

The list of items is the source of truth. Selection, highlighting, expansion states should reference items by ID. Derive the actual object when you need it by looking up the ID in the list.
