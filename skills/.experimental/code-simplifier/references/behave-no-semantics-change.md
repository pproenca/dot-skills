---
title: Forbid Subtle Semantic Changes
impact: CRITICAL
impactDescription: Semantic changes like null vs undefined or == vs === cause bugs that pass 95% of tests but fail in edge cases only discovered in production
tags: behave, semantics, null, undefined, equality, coercion
---

## Forbid Subtle Semantic Changes

The most dangerous simplifications are those that look equivalent but have different semantics. Null vs undefined, loose vs strict equality, truthy vs explicit checks - these distinctions matter. Code that appears cleaner may silently change behavior for edge cases that existing tests do not cover.

**Incorrect (changes null/undefined semantics):**

```typescript
// Before: explicitly checks for null
function getDisplayName(user: User | null): string {
  if (user === null) {
    return 'Anonymous';
  }
  return user.name;
}

// After "simplification": truthy check
function getDisplayName(user: User | null): string {
  return user ? user.name : 'Anonymous';
}
// Breaks: user with name = '' or name = 0 (if polymorphic)
```

**Correct (preserve explicit null check):**

```typescript
function getDisplayName(user: User | null): string {
  return user === null ? 'Anonymous' : user.name;
}
```

**Incorrect (changes equality semantics):**

```javascript
// Before: intentional loose equality for null/undefined
function isEmpty(value) {
  return value == null; // Catches both null and undefined
}

// After "simplification": strict equality
function isEmpty(value) {
  return value === null;
}
// Breaks: isEmpty(undefined) now returns false
```

**Correct (preserve loose equality when intentional):**

```javascript
function isEmpty(value) {
  return value == null; // Intentionally catches null and undefined
}
```

**Incorrect (changes short-circuit semantics):**

```python
# Before: returns 0 if items is empty list
def first_or_zero(items):
    return items[0] if items else 0

# After "simplification": uses or
def first_or_zero(items):
    return (items and items[0]) or 0
# Breaks: returns 0 when items[0] is 0, empty string, False, etc.
```

**Correct (preserve original semantics):**

```python
def first_or_zero(items):
    return items[0] if items else 0
```

**Incorrect (changes nil vs empty slice semantics):**

```go
// Before: returns nil when no results found
func findUsers(query string) []User {
    rows := db.Query(query)
    if len(rows) == 0 {
        return nil
    }
    return rows
}

// After "simplification": always returns initialized slice
func findUsers(query string) []User {
    results := make([]User, 0)
    rows := db.Query(query)
    results = append(results, rows...)
    return results
}
// Breaks: if findUsers("inactive") == nil { showEmptyState() }
// json.Marshal(nil slice) = "null", json.Marshal(empty slice) = "[]"
```

### When NOT to Apply

- When fixing a bug caused by incorrect semantics
- When the semantic difference is explicitly documented and approved
- When migrating to stricter types with full test coverage

### Benefits

- Edge cases continue working correctly
- No silent failures in production
- Behavior matches developer expectations
- Tests remain valid without modification
