---
title: Convert Prototype Constructors to class Syntax
impact: MEDIUM
impactDescription: enables static analysis of object shapes
tags: idiom, classes, prototype, oop
---

## Convert Prototype Constructors to class Syntax

Prototype assignments scattered across a file give TypeScript no single declaration to type fields, methods, and inheritance from, so instances end up loosely typed and `this` is unchecked. A `class` consolidates the shape into one declaration the compiler can analyze fully, including visibility, `readonly`, and constructor parameter properties.

**Incorrect (prototype-based — no coherent instance type):**

```typescript
function Cart(currency) {
  this.currency = currency
  this.items = []
}
Cart.prototype.add = function (item) {
  this.items.push(item) // this is untyped; items could be anything
}
```

**Correct (class — one analyzable declaration):**

```typescript
class Cart {
  private readonly items: LineItem[] = []

  constructor(private readonly currency: Currency) {}

  add(item: LineItem): void {
    this.items.push(item)
  }
}
```

Reference: [TypeScript Handbook: Classes](https://www.typescriptlang.org/docs/handbook/2/classes.html)
