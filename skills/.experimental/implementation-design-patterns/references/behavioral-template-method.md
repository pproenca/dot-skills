---
title: Use Template Method to Fix an Algorithm Skeleton and Let Subclasses Override Steps
impact: MEDIUM
impactDescription: eliminates duplicated algorithm scaffolding across sibling classes by hoisting the shared sequence into a base class, lets subclasses override only the steps that legitimately vary, removes client conditionals that switch on subclass type
tags: behavioral, template-method, inheritance, algorithm-skeleton, hook
---

## Use Template Method to Fix an Algorithm Skeleton and Let Subclasses Override Steps

**Pattern intent:** define an algorithm's skeleton in a base class, allowing subclasses to override individual steps without changing the overall structure. Base class fixes "what" and "in what order"; subclasses fix "how" for the variable steps.

### Shapes to recognize

- Two or three classes whose top-level method looks nearly identical except for 1-2 inner steps
- A processing pipeline (parse → analyze → format → output) where parsing varies by format but the rest is shared
- Test fixtures with setUp/tearDown and a body — JUnit's `TestCase` is a Template Method
- "I keep copy-pasting this method and changing two lines"

### Problem

A data-mining app processes documents in PDF, DOC, and CSV formats — three classes with nearly identical processing code differing only in parsing logic. Client code adds conditionals to handle each type. Duplication accumulates as the algorithm evolves.

### Solution

Break the algorithm into discrete steps. Place the steps in a `templateMethod()` on a base class — the skeleton — and declare some steps abstract (subclasses must implement) and others virtual with defaults (subclasses may override). Hooks at strategic points let subclasses inject behavior without changing the algorithm itself.

**Incorrect (duplicated algorithm across siblings):**

```typescript
class PdfMiner {
  mine(file: string) {
    const raw = readFile(file);
    const text = parsePdf(raw);          // varies
    const data = analyze(text);          // shared
    const report = format(data);         // shared
    return writeReport(report);          // shared
  }
}

class CsvMiner {
  mine(file: string) {
    const raw = readFile(file);
    const text = parseCsv(raw);          // varies
    const data = analyze(text);          // duplicated
    const report = format(data);         // duplicated
    return writeReport(report);          // duplicated
  }
}
// Add DocMiner? Same duplication grows. Fix a bug in analyze? Edit it everywhere.
```

**Correct (skeleton in base class; subclasses fill in the variable steps):**

```typescript
/**
 * The Abstract Class defines a template method that contains a skeleton of some
 * algorithm, composed of calls to (usually) abstract primitive operations.
 *
 * Concrete subclasses should implement these operations, but leave the template
 * method itself intact.
 */
abstract class AbstractClass {
    /**
     * The template method defines the skeleton of an algorithm.
     */
    public templateMethod(): void {
        this.baseOperation1();
        this.requiredOperations1();
        this.baseOperation2();
        this.hook1();
        this.requiredOperation2();
        this.baseOperation3();
        this.hook2();
    }

    /**
     * These operations already have implementations.
     */
    protected baseOperation1(): void {
        console.log('AbstractClass says: I am doing the bulk of the work');
    }

    protected baseOperation2(): void {
        console.log('AbstractClass says: But I let subclasses override some operations');
    }

    protected baseOperation3(): void {
        console.log('AbstractClass says: But I am doing the bulk of the work anyway');
    }

    /**
     * These operations have to be implemented in subclasses.
     */
    protected abstract requiredOperations1(): void;

    protected abstract requiredOperation2(): void;

    /**
     * These are "hooks." Subclasses may override them, but it's not mandatory
     * since the hooks already have default (but empty) implementation. Hooks
     * provide additional extension points in some crucial places of the
     * algorithm.
     */
    protected hook1(): void { }

    protected hook2(): void { }
}

/**
 * Concrete classes have to implement all abstract operations of the base class.
 * They can also override some operations with a default implementation.
 */
class ConcreteClass1 extends AbstractClass {
    protected requiredOperations1(): void {
        console.log('ConcreteClass1 says: Implemented Operation1');
    }

    protected requiredOperation2(): void {
        console.log('ConcreteClass1 says: Implemented Operation2');
    }
}

/**
 * Usually, concrete classes override only a fraction of base class' operations.
 */
class ConcreteClass2 extends AbstractClass {
    protected requiredOperations1(): void {
        console.log('ConcreteClass2 says: Implemented Operation1');
    }

    protected requiredOperation2(): void {
        console.log('ConcreteClass2 says: Implemented Operation2');
    }

    protected hook1(): void {
        console.log('ConcreteClass2 says: Overridden Hook1');
    }
}

/**
 * The client code calls the template method to execute the algorithm. Client
 * code does not have to know the concrete class of an object it works with, as
 * long as it works with objects through the interface of their base class.
 */
function clientCode(abstractClass: AbstractClass) {
    abstractClass.templateMethod();
}

console.log('Same client code can work with different subclasses:');
clientCode(new ConcreteClass1());
console.log('');

console.log('Same client code can work with different subclasses:');
clientCode(new ConcreteClass2());
```

**Output:**

```text
Same client code can work with different subclasses:
AbstractClass says: I am doing the bulk of the work
ConcreteClass1 says: Implemented Operation1
AbstractClass says: But I let subclasses override some operations
ConcreteClass1 says: Implemented Operation2
AbstractClass says: But I am doing the bulk of the work anyway

Same client code can work with different subclasses:
AbstractClass says: I am doing the bulk of the work
ConcreteClass2 says: Implemented Operation1
AbstractClass says: But I let subclasses override some operations
ConcreteClass2 says: Overridden Hook1
ConcreteClass2 says: Implemented Operation2
AbstractClass says: But I am doing the bulk of the work anyway
```

### When to use

- Extend particular algorithm steps without modifying the whole algorithm
- Several classes have nearly identical algorithms with minor differences
- Eliminate conditionals in client code by leaning on polymorphism
- A shared algorithm structure must span multiple implementations

### When NOT to use

- The algorithm varies fundamentally between subclasses — composition (Strategy) suits better
- Subclasses cannot meaningfully override the steps without violating Liskov substitution
- Only one variant exists — Template Method is overhead

### Implementation Steps

1. Analyze the target algorithm for discrete steps; identify common vs unique steps
2. Create an abstract base class with the template method and abstract methods for the variable steps; consider marking the template method `final`-equivalent (TypeScript lacks `final`, use convention)
3. Provide default implementations where reasonable; leave others abstract
4. Add hooks between crucial steps as optional extension points
5. Create concrete subclasses implementing all abstract steps

### Pros

- Clients override only specific parts; less affected by changes elsewhere
- Duplicate code consolidates into the superclass

### Cons

- Some clients limited by the algorithm skeleton
- May violate Liskov Substitution if a subclass suppresses default step implementations
- Maintenance difficulty rises with more steps

### Related Patterns

- **Factory Method** — specialization of Template Method (one step is a factory)
- **Strategy** — Strategy uses composition (swap at runtime); Template Method uses inheritance (compile-time)
- **Decorator** — alternative when extension must happen at runtime per-instance

Reference: [refactoring.guru/design-patterns/template-method](https://refactoring.guru/design-patterns/template-method)
