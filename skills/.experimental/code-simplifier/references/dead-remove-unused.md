---
title: Delete Unused Code Artifacts
impact: MEDIUM
impactDescription: Unused code increases cognitive load, slows comprehension, and creates false dependency signals during refactoring
tags: dead, unused, variables, functions, imports, parameters
---

## Delete Unused Code Artifacts

Unused variables, functions, imports, and parameters are noise that obscures the real logic. They force readers to track dead references, bloat bundle sizes, and create phantom dependencies that complicate refactoring. Modern tooling catches unused code - delete it immediately rather than leaving it "just in case."

**Incorrect (unused artifacts throughout):**

```typescript
import { useState, useEffect, useCallback, useMemo } from 'react';
import { formatDate, parseDate, isValidDate } from './dateUtils';
import { API_URL, MAX_RETRIES, TIMEOUT } from './constants';

interface UserListProps {
  users: User[];
  onSelect: (user: User) => void;
  showAvatar: boolean;  // Never used in component
  maxItems: number;     // Never used in component
}

export function UserList({ users, onSelect, showAvatar, maxItems }: UserListProps) {
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);  // Never used
  const [error, setError] = useState<Error | null>(null);  // Never used

  const sortedUsers = useMemo(() => users, [users]);  // Memo does nothing

  const handleClick = useCallback((user: User) => {
    setSelectedId(user.id);
    onSelect(user);
  }, [onSelect]);

  const unusedHelper = (data: unknown) => {  // Never called
    return formatDate(data as Date);
  };

  return (
    <ul>
      {sortedUsers.map(user => (
        <li key={user.id} onClick={() => handleClick(user)}>
          {user.name}
        </li>
      ))}
    </ul>
  );
}
```

**Correct (only what's needed):**

```typescript
import { useState, useCallback } from 'react';

interface UserListProps {
  users: User[];
  onSelect: (user: User) => void;
}

export function UserList({ users, onSelect }: UserListProps) {
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const handleClick = useCallback((user: User) => {
    setSelectedId(user.id);
    onSelect(user);
  }, [onSelect]);

  return (
    <ul>
      {users.map(user => (
        <li key={user.id} onClick={() => handleClick(user)}>
          {user.name}
        </li>
      ))}
    </ul>
  );
}
```

**Incorrect (unused function parameters):**

```python
def calculate_discount(price, quantity, customer_type, region, currency, promo_code):
    """Only price and quantity are actually used."""
    return price * quantity * 0.9

def process_order(order, config, logger, metrics, cache):
    """Only order is used."""
    return order.total
```

**Correct (remove unused parameters or mark intentionally ignored):**

```python
def calculate_discount(price, quantity):
    return price * quantity * 0.9

def process_order(order, _config, _logger, _metrics, _cache):
    """Underscore prefix signals intentionally unused (interface compliance)."""
    return order.total
```

### When NOT to Apply

- Interface compliance requires the parameter signature (use underscore prefix)
- Public API where removal would be a breaking change
- Parameters used only in debug/logging modes
- Imports used only in type annotations (may appear unused to some tools)

### Benefits

- 20-40% reduction in lines of code in cluttered files
- Faster code comprehension for new developers
- Smaller bundle sizes (tree-shaking works better)
- Clearer dependency graphs for refactoring tools
- Eliminates false positives in static analysis

### References

- ESLint: no-unused-vars, no-unused-imports
- TypeScript: noUnusedLocals, noUnusedParameters
- Python: F401 (unused import), F841 (unused variable)
