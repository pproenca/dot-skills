---
title: Never Modify Built-in Prototypes
impact: CRITICAL
impactDescription: prevents global conflicts and breaking changes
tags: lang, prototypes, built-ins, monkey-patching
---

## Never Modify Built-in Prototypes

Never add, modify, or delete properties from built-in object prototypes. This causes conflicts between libraries and breaks future ECMAScript compatibility.

**Incorrect (modifying Array prototype):**

```javascript
// Adding custom method to Array prototype
Array.prototype.first = function() {
  return this[0];
};

Array.prototype.last = function() {
  return this[this.length - 1];
};

const orders = [{ id: 1 }, { id: 2 }, { id: 3 }];
console.log(orders.first().id);  // Works but pollutes global
```

**Correct (standalone utility functions):**

```javascript
function first(array) {
  return array[0];
}

function last(array) {
  return array[array.length - 1];
}

const orders = [{ id: 1 }, { id: 2 }, { id: 3 }];
console.log(first(orders).id);  // Explicit, no global pollution
```

**Alternative (class extension for custom types):**

```javascript
class OrderList extends Array {
  first() {
    return this[0];
  }

  last() {
    return this[this.length - 1];
  }
}

const orders = OrderList.from([{ id: 1 }, { id: 2 }]);
console.log(orders.first().id);
```

**Why this matters:**
- Future JS versions may add conflicting methods
- Other libraries may have different implementations
- Polyfills may behave unexpectedly

Reference: [Google JavaScript Style Guide - Modifying builtin objects](https://google.github.io/styleguide/jsguide.html#disallowed-features-modifying-builtin-objects)
