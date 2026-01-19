---
title: Handle Computed Property Keys in Filters
impact: HIGH
impactDescription: prevents missed transforms on dynamic object keys
tags: filter, computed, dynamic, object-keys
---

## Handle Computed Property Keys in Filters

Computed property keys (`[expression]`) don't have a `name` property. Filters assuming string keys miss computed properties.

**Incorrect (assumes static key):**

```javascript
// Finds static property 'status' but misses computed ones
root.find(j.Property, {
  key: { name: 'status' }
});

// Finds: { status: 'active' }
// Misses: { [STATUS_KEY]: 'active' }
// Misses: { ['stat' + 'us']: 'active' }
```

**Correct (handles both static and computed):**

```javascript
root.find(j.Property)
  .filter(path => {
    const key = path.node.key;

    // Static identifier key
    if (key.type === 'Identifier' && key.name === 'status') {
      return true;
    }

    // String literal key (less common but valid)
    if (key.type === 'Literal' && key.value === 'status') {
      return true;
    }

    // Computed key - can only match if it's a simple identifier
    if (path.node.computed && key.type === 'Identifier') {
      // This is [STATUS_KEY], we can't know the runtime value
      // Log for manual review or check known constants
      return key.name === 'STATUS_KEY';
    }

    return false;
  });
```

**Alternative (for object patterns/destructuring):**

```javascript
root.find(j.ObjectPattern)
  .find(j.Property)
  .filter(path => {
    // In destructuring, check both key and value
    // { status: localStatus } - key is 'status'
    // { [STATUS_KEY]: localStatus } - computed
    const key = path.node.key;
    return !path.node.computed && key.name === 'status';
  });
```

**Note:** Computed keys are inherently dynamic. Consider logging them for manual review rather than attempting transformation.

Reference: [Mozilla Parser API - Property](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/SpiderMonkey/Parser_API)
