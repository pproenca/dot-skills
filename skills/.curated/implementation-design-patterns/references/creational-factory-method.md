---
title: Use Factory Method to Decouple Object Creation from Concrete Classes
impact: HIGH
impactDescription: eliminates direct `new ConcreteX()` calls scattered through callers, isolates product instantiation so adding a new product type touches only one creator subclass instead of every call site
tags: creational, factory-method, polymorphic-creation, inheritance, open-closed
---

## Use Factory Method to Decouple Object Creation from Concrete Classes

**Pattern intent:** an interface for creating objects in a superclass, but subclasses decide which concrete class to instantiate. The superclass holds the business logic that consumes products; subclasses pick the product type.

### Shapes to recognize

- A class scattered with `new Truck()`, `new Ship()`, `new Drone()` calls whose behavior is otherwise identical — adding a 4th transport requires hunting through the file
- A `switch (type)` block inside a constructor or static helper that returns different subclasses
- A library you want users to extend, but the library hard-codes the products it creates
- "I want to override what gets instantiated, but I don't want to override the whole method"

### Problem

A logistics app coupled to `Truck` faces difficulty when adding `Ship`: code that operates on transports is tightly coupled to the concrete class. Each new transport type spreads conditional logic across the codebase.

### Solution

Replace direct construction calls with invocations of a factory method declared on the creator. Objects are still created with `new`, but the call lives inside the factory method, which subclasses override to return different products. All products share a common interface so callers stay product-agnostic.

**Incorrect (caller couples directly to concrete classes):**

```typescript
class LogisticsApp {
  planRoute(transportKind: 'truck' | 'ship') {
    if (transportKind === 'truck') {
      const truck = new Truck();
      truck.deliver();
    } else if (transportKind === 'ship') {
      const ship = new Ship();
      ship.deliver();
    }
    // Adding `new Drone()` here forces edits in every method that plans routes.
  }
}
```

**Correct (subclasses override the factory method):**

```typescript
/**
 * The Creator class declares the factory method that is supposed to return an
 * object of a Product class. The Creator's subclasses usually provide the
 * implementation of this method.
 */
abstract class Creator {
    /**
     * Note that the Creator may also provide some default implementation of the
     * factory method.
     */
    public abstract factoryMethod(): Product;

    /**
     * Also note that, despite its name, the Creator's primary responsibility is
     * not creating products. Usually, it contains some core business logic that
     * relies on Product objects, returned by the factory method. Subclasses can
     * indirectly change that business logic by overriding the factory method
     * and returning a different type of product from it.
     */
    public someOperation(): string {
        const product = this.factoryMethod();
        return `Creator: The same creator's code has just worked with ${product.operation()}`;
    }
}

/**
 * Concrete Creators override the factory method in order to change the
 * resulting product's type.
 */
class ConcreteCreator1 extends Creator {
    public factoryMethod(): Product {
        return new ConcreteProduct1();
    }
}

class ConcreteCreator2 extends Creator {
    public factoryMethod(): Product {
        return new ConcreteProduct2();
    }
}

/**
 * The Product interface declares the operations that all concrete products must
 * implement.
 */
interface Product {
    operation(): string;
}

class ConcreteProduct1 implements Product {
    public operation(): string {
        return '{Result of the ConcreteProduct1}';
    }
}

class ConcreteProduct2 implements Product {
    public operation(): string {
        return '{Result of the ConcreteProduct2}';
    }
}

/**
 * The client code works with an instance of a concrete creator, albeit through
 * its base interface. As long as the client keeps working with the creator via
 * the base interface, you can pass it any creator's subclass.
 */
function clientCode(creator: Creator) {
    console.log('Client: I\'m not aware of the creator\'s class, but it still works.');
    console.log(creator.someOperation());
}

console.log('App: Launched with the ConcreteCreator1.');
clientCode(new ConcreteCreator1());
console.log('');

console.log('App: Launched with the ConcreteCreator2.');
clientCode(new ConcreteCreator2());
```

**Output:**

```text
App: Launched with the ConcreteCreator1.
Client: I'm not aware of the creator's class, but it still works.
Creator: The same creator's code has just worked with {Result of the ConcreteProduct1}

App: Launched with the ConcreteCreator2.
Client: I'm not aware of the creator's class, but it still works.
Creator: The same creator's code has just worked with {Result of the ConcreteProduct2}
```

### When to use

- The exact type and dependencies of the objects your code instantiates are unknown beforehand
- You are building a library/framework and want users to extend internal components through inheritance
- You want to reuse existing objects (object pool, cache) instead of rebuilding them — the factory method is the natural place to insert the lookup

### When NOT to use

- The number of product types is fixed and small, and the construction logic is trivial — a plain `new` suffices
- You only need one variant — introducing a creator hierarchy is dead weight
- You need to vary a *family* of related objects together — reach for **Abstract Factory** instead

### Implementation Steps

1. Ensure all products implement the same interface
2. Add an empty factory method to the creator class with return type matching the product interface
3. Replace product constructor references in the creator with factory-method calls
4. Create a creator subclass for each product type, overriding the factory method
5. If the creator has many product variants, consider passing control parameters to the factory method
6. Make the base factory method abstract, or provide a default implementation if there is a sensible default

### Pros

- Avoids tight coupling between creator and concrete products
- Centralizes product creation, improving maintainability (Single Responsibility)
- Enables introducing new product types without breaking existing client code (Open/Closed)

### Cons

- Code complexity increases due to numerous new subclasses required for implementation

### Related Patterns

- **Abstract Factory** — often evolves from Factory Method when you need *families* of related products
- **Prototype** — alternative when inheritance is not desirable; clone configured instances instead
- **Template Method** — Factory Method is often a single step inside a Template Method
- **Iterator** — collections frequently expose iterators via a factory method

Reference: [refactoring.guru/design-patterns/factory-method](https://refactoring.guru/design-patterns/factory-method)
