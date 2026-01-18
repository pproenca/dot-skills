---
title: Use ES6 Classes Over Prototype Manipulation
impact: HIGH
impactDescription: improves readability and enables tooling support
tags: lang, classes, prototypes, inheritance, es6
---

## Use ES6 Classes Over Prototype Manipulation

Use ES6 `class` syntax instead of manually manipulating prototypes. Classes provide clearer syntax, proper inheritance semantics, and better tooling support.

**Incorrect (manual prototype manipulation):**

```javascript
function OrderProcessor(config) {
  this.config = config;
  this.processedCount = 0;
}

OrderProcessor.prototype.process = function(order) {
  this.processedCount++;
  return { ...order, processed: true };
};

OrderProcessor.prototype.getStats = function() {
  return { processed: this.processedCount };
};

function PriorityOrderProcessor(config) {
  OrderProcessor.call(this, config);
  this.priorityThreshold = config.priorityThreshold;
}

PriorityOrderProcessor.prototype = Object.create(OrderProcessor.prototype);
PriorityOrderProcessor.prototype.constructor = PriorityOrderProcessor;
```

**Correct (ES6 class syntax):**

```javascript
class OrderProcessor {
  constructor(config) {
    this.config = config;
    this.processedCount = 0;
  }

  process(order) {
    this.processedCount++;
    return { ...order, processed: true };
  }

  getStats() {
    return { processed: this.processedCount };
  }
}

class PriorityOrderProcessor extends OrderProcessor {
  constructor(config) {
    super(config);
    this.priorityThreshold = config.priorityThreshold;
  }
}
```

**Benefits:**
- Clearer inheritance chain
- `super` keyword for parent access
- Static methods with `static` keyword
- IDE autocompletion and refactoring support

Reference: [Google JavaScript Style Guide - Classes](https://google.github.io/styleguide/jsguide.html#features-classes)
