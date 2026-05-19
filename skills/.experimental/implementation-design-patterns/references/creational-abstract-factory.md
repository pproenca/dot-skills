---
title: Use Abstract Factory to Produce Families of Related Objects
impact: MEDIUM-HIGH
impactDescription: prevents mixing incompatible variants (e.g., Victorian chair with Modern sofa) by guaranteeing all objects returned from one factory belong to the same family, eliminates parallel `if (style === ...)` conditionals at every product-creation site
tags: creational, abstract-factory, product-family, polymorphic-creation, open-closed
---

## Use Abstract Factory to Produce Families of Related Objects

**Pattern intent:** an interface for creating *families* of related or dependent objects without specifying their concrete classes. Each concrete factory returns objects from a single variant; clients work with abstract products and never know which variant is active.

### Shapes to recognize

- Code that branches on a style/theme/variant *for every product it creates*: `if (style === 'modern') new ModernChair(); else new VictorianChair();` repeated for chair, sofa, table
- Risk of accidentally pairing incompatible variants (a Victorian chair next to a Modern sofa)
- Cross-platform UI code where button + checkbox + dialog must all match the host OS
- "I have N parallel hierarchies that must vary together"

### Problem

You produce furniture in variants (Modern, Victorian, ArtDeco) and need chair+sofa+table from the same family. Adding a new variant shouldn't require editing every product-creation site, and clients must not mix families.

### Solution

Declare an abstract product interface per product type (Chair, Sofa, Table). Declare an Abstract Factory interface with one creation method per product type. Each concrete factory corresponds to one variant and returns matching products. Clients hold a reference to the abstract factory and never name a concrete class.

**Incorrect (parallel conditionals risk mixing families):**

```typescript
class FurnitureShop {
  buildLivingRoom(style: 'modern' | 'victorian') {
    // Each call site duplicates the style branch — if a new style ships,
    // every method that creates furniture must be updated.
    const chair = style === 'modern' ? new ModernChair() : new VictorianChair();
    const sofa  = style === 'modern' ? new ModernSofa()  : new VictorianSofa();
    // Easy to mix accidentally:
    const table = new ModernTable(); // oops — should have been Victorian
    return { chair, sofa, table };
  }
}
```

**Correct (one factory per family, compatibility guaranteed):**

```typescript
/**
 * The Abstract Factory interface declares a set of methods that return
 * different abstract products. These products are called a family and are
 * related by a high-level theme or concept. Products of one family are usually
 * able to collaborate among themselves. A family of products may have several
 * variants, but the products of one variant are incompatible with products of
 * another.
 */
interface AbstractFactory {
    createProductA(): AbstractProductA;
    createProductB(): AbstractProductB;
}

/**
 * Concrete Factories produce a family of products that belong to a single
 * variant. The factory guarantees that resulting products are compatible.
 */
class ConcreteFactory1 implements AbstractFactory {
    public createProductA(): AbstractProductA {
        return new ConcreteProductA1();
    }

    public createProductB(): AbstractProductB {
        return new ConcreteProductB1();
    }
}

class ConcreteFactory2 implements AbstractFactory {
    public createProductA(): AbstractProductA {
        return new ConcreteProductA2();
    }

    public createProductB(): AbstractProductB {
        return new ConcreteProductB2();
    }
}

interface AbstractProductA {
    usefulFunctionA(): string;
}

class ConcreteProductA1 implements AbstractProductA {
    public usefulFunctionA(): string {
        return 'The result of the product A1.';
    }
}

class ConcreteProductA2 implements AbstractProductA {
    public usefulFunctionA(): string {
        return 'The result of the product A2.';
    }
}

interface AbstractProductB {
    usefulFunctionB(): string;
    anotherUsefulFunctionB(collaborator: AbstractProductA): string;
}

class ConcreteProductB1 implements AbstractProductB {
    public usefulFunctionB(): string {
        return 'The result of the product B1.';
    }

    public anotherUsefulFunctionB(collaborator: AbstractProductA): string {
        const result = collaborator.usefulFunctionA();
        return `The result of the B1 collaborating with the (${result})`;
    }
}

class ConcreteProductB2 implements AbstractProductB {
    public usefulFunctionB(): string {
        return 'The result of the product B2.';
    }

    public anotherUsefulFunctionB(collaborator: AbstractProductA): string {
        const result = collaborator.usefulFunctionA();
        return `The result of the B2 collaborating with the (${result})`;
    }
}

/**
 * The client code works with factories and products only through abstract
 * types: AbstractFactory and AbstractProduct. This lets you pass any factory or
 * product subclass to the client code without breaking it.
 */
function clientCode(factory: AbstractFactory) {
    const productA = factory.createProductA();
    const productB = factory.createProductB();

    console.log(productB.usefulFunctionB());
    console.log(productB.anotherUsefulFunctionB(productA));
}

console.log('Client: Testing client code with the first factory type...');
clientCode(new ConcreteFactory1());

console.log('');

console.log('Client: Testing the same client code with the second factory type...');
clientCode(new ConcreteFactory2());
```

**Output:**

```text
Client: Testing client code with the first factory type...
The result of the product B1.
The result of the B1 collaborating with the (The result of the product A1.)

Client: Testing the same client code with the second factory type...
The result of the product B2.
The result of the B2 collaborating with the (The result of the product A2.)
```

### When to use

- Your code must work with several families of related products and you don't want it depending on concrete classes
- Product variants are unknown beforehand, or you want to add new ones without breaking client code
- A class containing several Factory Methods that all switch on the same variant — extract them into a family

### When NOT to use

- You have only one product type — use **Factory Method**
- You have only one variant — there's no family to enforce
- Products in the family don't actually need to match — coupling them with one factory creates artificial coordination

### Implementation Steps

1. Map distinct product types versus their variants (a matrix: product × variant)
2. Declare abstract product interfaces; implement concrete products per interface
3. Declare the abstract factory interface with one creation method per product type
4. Implement concrete factories for each variant
5. Add factory-initialization code that picks the right factory based on configuration or environment
6. Replace direct constructor calls with factory creation methods

### Pros

- Guarantees product compatibility across families
- Avoids tight coupling between concrete products and client code
- Centralizes product creation (Single Responsibility)
- Enables new variants without breaking existing code (Open/Closed)

### Cons

- Introduces significant complexity through new interfaces and classes — overkill for a single product type or single variant

### Related Patterns

- **Factory Method** — Abstract Factory often evolves from a class with several Factory Methods
- **Builder** — Builder constructs one complex product step by step; Abstract Factory returns a family immediately
- **Prototype** — concrete factories may implement their methods via clone
- **Facade** — Abstract Factory can hide creation behind a simple Facade
- **Singleton** — concrete factories are often Singletons

Reference: [refactoring.guru/design-patterns/abstract-factory](https://refactoring.guru/design-patterns/abstract-factory)
