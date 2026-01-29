---
title: Flatten deeply nested state
impact: HIGH
impactDescription: Deep nesting makes updates verbose and error-prone; flat structures with ID references are easier to update
tags: [state, structure, normalization, nesting, flat]
---

# Flatten Deeply Nested State

Deeply nested state is hard to update correctly. Flatten it like a database: store items by ID in an object, and reference children by their IDs.

## Why This Matters

Flat state:
- Makes updates simple (just update one object)
- Avoids spreading through multiple levels
- Matches how databases organize data
- Enables easier selection and filtering

**Incorrect (anti-pattern):**

```tsx
// Problem: Deeply nested tree structure
interface Place {
  id: number;
  title: string;
  childPlaces: Place[];  // Nested children
}

function TravelPlan() {
  const [plan, setPlan] = useState<Place>({
    id: 0,
    title: 'Root',
    childPlaces: [{
      id: 1,
      title: 'Earth',
      childPlaces: [{
        id: 2,
        title: 'Africa',
        childPlaces: [{
          id: 3,
          title: 'Egypt',
          childPlaces: [],
        }]
      }]
    }]
  });

  // To delete Egypt (id: 3), you need to:
  // 1. Copy Root
  // 2. Copy Earth
  // 3. Copy Africa
  // 4. Filter out Egypt from Africa's children
  // 5. Rebuild the entire tree

  function deletePlace(idToDelete: number) {
    // This is EXTREMELY complex and error-prone
    function removeFromTree(place: Place): Place {
      return {
        ...place,
        childPlaces: place.childPlaces
          .filter(child => child.id !== idToDelete)
          .map(child => removeFromTree(child))
      };
    }
    setPlan(removeFromTree(plan));
  }
}
```

**Correct (recommended):**

```tsx
// Solution: Flat structure like a database table
interface Place {
  id: number;
  title: string;
  childIds: number[];  // References, not nested objects
}

type PlacesById = Record<number, Place>;

function TravelPlan() {
  const [placesById, setPlacesById] = useState<PlacesById>({
    0: { id: 0, title: 'Root', childIds: [1] },
    1: { id: 1, title: 'Earth', childIds: [2] },
    2: { id: 2, title: 'Africa', childIds: [3] },
    3: { id: 3, title: 'Egypt', childIds: [] },
  });

  function deletePlace(parentId: number, childId: number) {
    // Simple: just update the parent's childIds
    setPlacesById({
      ...placesById,
      [parentId]: {
        ...placesById[parentId],
        childIds: placesById[parentId].childIds.filter(id => id !== childId),
      },
    });
  }

  // Rendering a tree is still easy
  function PlaceTree({ id }: { id: number }) {
    const place = placesById[id];
    return (
      <li>
        {place.title}
        {place.childIds.length > 0 && (
          <ul>
            {place.childIds.map(childId => (
              <PlaceTree key={childId} id={childId} />
            ))}
          </ul>
        )}
      </li>
    );
  }

  return <ul><PlaceTree id={0} /></ul>;
}
```

## Complete Example with All Operations

```tsx
// Flat, normalized state structure
interface Category {
  id: string;
  name: string;
  itemIds: string[];
}

interface Item {
  id: string;
  name: string;
  price: number;
}

interface StoreState {
  categories: Record<string, Category>;
  items: Record<string, Item>;
  rootCategoryIds: string[];
}

function Store() {
  const [state, setState] = useState<StoreState>({
    categories: {
      'cat-1': { id: 'cat-1', name: 'Electronics', itemIds: ['item-1', 'item-2'] },
      'cat-2': { id: 'cat-2', name: 'Books', itemIds: ['item-3'] },
    },
    items: {
      'item-1': { id: 'item-1', name: 'Phone', price: 999 },
      'item-2': { id: 'item-2', name: 'Laptop', price: 1299 },
      'item-3': { id: 'item-3', name: 'Novel', price: 15 },
    },
    rootCategoryIds: ['cat-1', 'cat-2'],
  });

  // ADD an item - simple
  function addItem(categoryId: string, item: Item) {
    setState({
      ...state,
      items: { ...state.items, [item.id]: item },
      categories: {
        ...state.categories,
        [categoryId]: {
          ...state.categories[categoryId],
          itemIds: [...state.categories[categoryId].itemIds, item.id],
        },
      },
    });
  }

  // UPDATE an item - very simple
  function updateItem(itemId: string, updates: Partial<Item>) {
    setState({
      ...state,
      items: {
        ...state.items,
        [itemId]: { ...state.items[itemId], ...updates },
      },
    });
  }

  // DELETE an item - update category and items
  function deleteItem(categoryId: string, itemId: string) {
    const { [itemId]: removed, ...remainingItems } = state.items;
    setState({
      ...state,
      items: remainingItems,
      categories: {
        ...state.categories,
        [categoryId]: {
          ...state.categories[categoryId],
          itemIds: state.categories[categoryId].itemIds.filter(id => id !== itemId),
        },
      },
    });
  }
}
```

## Using Immer for Complex Updates

```tsx
// Immer makes flat state updates even simpler
import { useImmer } from 'use-immer';

function TravelPlan() {
  const [placesById, updatePlaces] = useImmer<PlacesById>(initialPlaces);

  function deletePlace(parentId: number, childId: number) {
    updatePlaces(draft => {
      // Mutate the draft - Immer handles immutability
      draft[parentId].childIds = draft[parentId].childIds.filter(
        id => id !== childId
      );
      delete draft[childId];  // Also remove the deleted place
    });
  }
}
```

## Nested vs Flat Comparison

| Operation | Deeply Nested | Flat |
|-----------|--------------|------|
| Add leaf | Copy entire path | Add to dict + parent's childIds |
| Delete leaf | Rebuild entire tree | Remove from dict + parent's childIds |
| Update deep item | Copy entire path | Update single dict entry |
| Move item | Complex tree surgery | Update two parents' childIds |

## Key Principle

State structure should match how you update it. If updates are always "find by ID, modify", store by ID. Think of your state like a relational database: entities in tables, relationships via IDs.
