---
title: Inspect Memory and Object State
impact: MEDIUM-HIGH
impactDescription: Catches 90%+ of reference vs value bugs; reveals prototype chain and hidden properties
tags: tool, memory, inspection, objects, state
---

## Inspect Memory and Object State

Expand objects fully in the debugger to see their complete state. Shallow inspection misses nested problems, prototype issues, and non-enumerable properties.

**Incorrect (shallow inspection):**

```javascript
// Bug: Object comparison fails even though they "look equal"
const user1 = await getUser(id);
const user2 = await getUserFromCache(id);

console.log(user1);  // {name: "Alice", age: 30}
console.log(user2);  // {name: "Alice", age: 30}

if (user1 === user2) {  // false - WHY?
  // ...
}

// Shallow inspection shows same values, bug seems impossible
```

**Correct (deep object inspection):**

```javascript
// In debugger, expand objects fully:

user1 = {
  name: "Alice",
  age: 30,
  __proto__: Object.prototype,
  [[ObjectId]]: 12345        // ← Different reference!
}

user2 = {
  name: "Alice",
  age: 30,
  __proto__: Object.prototype,
  [[ObjectId]]: 67890        // ← Different reference!
}

// Also check hidden properties:
console.log(Object.getOwnPropertyDescriptors(user1));
// Reveals: writable, enumerable, configurable flags

console.log(user1.__proto__ === user2.__proto__);  // Check prototype

// Found it: They're different object instances
// Need to compare by value, not reference
```

**Deep inspection techniques:**

```python
# Python: Use vars() or __dict__
print(vars(user))
print(user.__dict__)
print(dir(user))  # All attributes including inherited

# Check type and class
print(type(user))
print(user.__class__.__mro__)  # Method resolution order

# For complex objects
import json
print(json.dumps(user.__dict__, indent=2, default=str))
```

**What to look for in object inspection:**

| Problem | What to Check |
|---------|---------------|
| Identity vs equality | Object IDs/references |
| Missing properties | Enumerable vs non-enumerable |
| Inheritance issues | Prototype chain |
| Lazy loading | Property getters, proxies |
| Circular references | Parent/child pointers |
| Type coercion | Actual types vs displayed values |

**When NOT to use this pattern:**
- Simple primitive values
- Performance profiling (use profiler instead)

Reference: [Chrome DevTools - Object Inspection](https://developer.chrome.com/docs/devtools/javascript/reference/#scope)
