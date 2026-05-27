---
title: Use Visitor to Add Operations to Class Hierarchies Without Modifying Them
impact: LOW-MEDIUM
impactDescription: enables adding new operations (export, validate, render, optimize) across a closed object hierarchy by writing a new visitor class instead of editing every node type, isolates each new operation in one place rather than scattering it across the hierarchy
tags: behavioral, visitor, double-dispatch, ast-traversal, open-classes
---

## Use Visitor to Add Operations to Class Hierarchies Without Modifying Them

**Pattern intent:** separate algorithms from the objects they operate on. New operations across a stable class hierarchy go into a Visitor; each element accepts the visitor and dispatches to the matching visit method. Double dispatch lets the visitor know the exact element type without `instanceof`.

### Shapes to recognize

- An AST, geometric scene graph, or document tree with many node types
- New operations needed across the hierarchy (export to XML, type-check, render, optimize) — and you can't touch the node classes
- Each new operation currently means adding a method to every node class — N×M growth
- "I need 5 unrelated operations across 20 node types"

### Problem

A production system with geographic data nodes needs XML export, but the architect prohibits changing existing node classes (stability concerns, single-responsibility violation if every operation lives on every node).

### Solution

Place each new behavior in a separate Visitor class. Each element class implements `accept(visitor)` that calls back into `visitor.visitConcreteX(this)`. The visitor exposes one method per concrete element type — double dispatch routes the call to the right pair (visitor type × element type) without `instanceof`.

**Incorrect (every new operation touches every node class):**

```typescript
class Building { exportXml() { /* ... */ } typeCheck() { /* ... */ } optimize() { /* ... */ } }
class Road     { exportXml() { /* ... */ } typeCheck() { /* ... */ } optimize() { /* ... */ } }
class Park     { exportXml() { /* ... */ } typeCheck() { /* ... */ } optimize() { /* ... */ } }
// Add `renderForVR`? Edit every class. The hierarchy can't stay closed.
```

**Correct (operation lives in a visitor; nodes accept it):**

```typescript
/**
 * The Component interface declares an `accept` method that should take the base
 * visitor interface as an argument.
 */
interface Component {
    accept(visitor: Visitor): void;
}

/**
 * Each Concrete Component must implement the `accept` method in such a way that
 * it calls the visitor's method corresponding to the component's class.
 */
class ConcreteComponentA implements Component {
    /**
     * Note that we're calling `visitConcreteComponentA`, which matches the
     * current class name. This way we let the visitor know the class of the
     * component it works with.
     */
    public accept(visitor: Visitor): void {
        visitor.visitConcreteComponentA(this);
    }

    /**
     * Concrete Components may have special methods that don't exist in their
     * base class or interface. The Visitor is still able to use these methods
     * since it's aware of the component's concrete class.
     */
    public exclusiveMethodOfConcreteComponentA(): string {
        return 'A';
    }
}

class ConcreteComponentB implements Component {
    /**
     * Same here: visitConcreteComponentB => ConcreteComponentB
     */
    public accept(visitor: Visitor): void {
        visitor.visitConcreteComponentB(this);
    }

    public specialMethodOfConcreteComponentB(): string {
        return 'B';
    }
}

/**
 * The Visitor Interface declares a set of visiting methods that correspond to
 * component classes. The signature of a visiting method allows the visitor to
 * identify the exact class of the component that it's dealing with.
 */
interface Visitor {
    visitConcreteComponentA(element: ConcreteComponentA): void;

    visitConcreteComponentB(element: ConcreteComponentB): void;
}

/**
 * Concrete Visitors implement several versions of the same algorithm, which can
 * work with all concrete component classes.
 */
class ConcreteVisitor1 implements Visitor {
    public visitConcreteComponentA(element: ConcreteComponentA): void {
        console.log(`${element.exclusiveMethodOfConcreteComponentA()} + ConcreteVisitor1`);
    }

    public visitConcreteComponentB(element: ConcreteComponentB): void {
        console.log(`${element.specialMethodOfConcreteComponentB()} + ConcreteVisitor1`);
    }
}

class ConcreteVisitor2 implements Visitor {
    public visitConcreteComponentA(element: ConcreteComponentA): void {
        console.log(`${element.exclusiveMethodOfConcreteComponentA()} + ConcreteVisitor2`);
    }

    public visitConcreteComponentB(element: ConcreteComponentB): void {
        console.log(`${element.specialMethodOfConcreteComponentB()} + ConcreteVisitor2`);
    }
}

/**
 * The client code can run visitor operations over any set of elements without
 * figuring out their concrete classes. The accept operation directs a call to
 * the appropriate operation in the visitor object.
 */
function clientCode(components: Component[], visitor: Visitor) {
    for (const component of components) {
        component.accept(visitor);
    }
}

const components = [
    new ConcreteComponentA(),
    new ConcreteComponentB(),
];

console.log('The client code works with all visitors via the base Visitor interface:');
const visitor1 = new ConcreteVisitor1();
clientCode(components, visitor1);
console.log('');

console.log('It allows the same client code to work with different types of visitors:');
const visitor2 = new ConcreteVisitor2();
clientCode(components, visitor2);
```

**Output:**

```text
The client code works with all visitors via the base Visitor interface:
A + ConcreteVisitor1
B + ConcreteVisitor1

It allows the same client code to work with different types of visitors:
A + ConcreteVisitor2
B + ConcreteVisitor2
```

### When to use

- Perform many unrelated operations on all elements of a complex object structure (object trees, ASTs)
- Extract auxiliary behaviors and clean up business logic in primary classes
- A behavior makes sense only in some classes of a hierarchy, not all

### When NOT to use

- The element hierarchy is unstable — every new element type forces updating every visitor
- The hierarchy is small and only one operation exists across it
- Visitors require access to private fields they shouldn't see — Visitor exposes shape and breaks encapsulation
- TypeScript discriminated unions + a `switch(node.kind)` exhaustive check often replaces Visitor more clearly for AST-like structures

### Implementation Steps

1. Declare the visitor interface with one `visitX` method per concrete element class
2. Add `accept(visitor)` to the element base interface
3. Implement `accept` in each concrete element, redirecting to the visitor's matching method (double dispatch)
4. Element classes work with visitors only through the visitor interface
5. Create concrete visitor classes, one per new operation
6. Pass visitors to elements via their `accept` methods

### Pros

- Open/Closed Principle: introduce new operations without changing existing classes
- Single Responsibility: each operation lives in one visitor class
- Visitors can accumulate state while traversing the structure

### Cons

- Adding or removing an element class forces updating every visitor
- Visitors may lack access to private fields and methods of elements

### Related Patterns

- **Command** — Visitor extends Command-like dispatch to operate across different object classes via double dispatch
- **Composite** — pairs effectively with Visitor for traversing object trees
- **Iterator** — traverse the structure with an Iterator while applying a Visitor at each element

Reference: [refactoring.guru/design-patterns/visitor](https://refactoring.guru/design-patterns/visitor)
