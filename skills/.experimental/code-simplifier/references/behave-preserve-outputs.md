---
title: Preserve All Return Values and Outputs
impact: CRITICAL
impactDescription: Changed outputs cause cascading failures in dependent code, often detected only in production
tags: behave, outputs, return-values, testing
---

## Preserve All Return Values and Outputs

Code simplification must never alter what a function returns. Even "equivalent" values like empty array vs null, or reordered object keys, can break downstream consumers. Every output - return values, yielded items, emitted events - must remain byte-for-byte identical.

**Incorrect (changes return type from null to undefined):**

```typescript
// Before: returns null for missing users
function findUser(id: string): User | null {
  const user = users.find(u => u.id === id);
  if (!user) {
    return null;
  }
  return user;
}

// After "simplification": now returns undefined
function findUser(id: string): User | undefined {
  return users.find(u => u.id === id);
}
// Breaks: if (findUser(id) === null) { ... }
```

**Correct (preserves null return type):**

```typescript
function findUser(id: string): User | null {
  return users.find(u => u.id === id) ?? null;
}
```

**Incorrect (changes output ordering):**

```python
# Before: returns sorted by insertion order
def get_config():
    return {"host": "localhost", "port": 8080, "debug": True}

# After "simplification": alphabetical order
def get_config():
    return dict(sorted({"debug": True, "host": "localhost", "port": 8080}.items()))
# Breaks: code that relies on iteration order or serialization
```

**Correct (preserves original ordering):**

```python
def get_config():
    return {"host": "localhost", "port": 8080, "debug": True}
```

### Benefits

- Downstream code continues working without modification
- Tests remain valid without updates
- API contracts stay honored
- Serialized outputs remain compatible
