---
title: Use Builder to Construct Complex Objects Step by Step
impact: HIGH
impactDescription: eliminates telescoping-constructor smell (constructors with 10+ parameters and many overloads), prevents subclass explosion for every parameter combination, allows the same construction sequence to produce different representations
tags: creational, builder, step-by-step, telescoping-constructor, director
---

## Use Builder to Construct Complex Objects Step by Step

**Pattern intent:** separate the construction of a complex object from its representation, so the same construction process can create different representations. Each construction step lives on a builder; an optional director orchestrates the sequence.

### Shapes to recognize

- A constructor with 8+ parameters, many optional, often `null`/`undefined` placeholders at call sites
- Multiple overloaded constructors covering subsets of parameters (telescoping constructor)
- A subclass per parameter combination — `HouseWithGarageAndPool`, `HouseWithGarageOnly`, etc.
- Deferred construction — you want to assemble a tree of objects in stages without exposing the half-built result
- The "fluent builder" call chain: `new Q().select(...).where(...).limit(...).build()`

### Problem

Complex objects need many fields and nested objects initialized. Unwieldy constructors with numerous parameters bury intent at call sites; creating subclasses for every configuration explodes the class count.

### Solution

Extract construction into a separate builder object that exposes one method per construction step. Clients call only the steps they need. Different concrete builders can produce different product representations from the same sequence of calls. An optional Director encapsulates well-known construction recipes.

**Incorrect (telescoping constructor):**

```typescript
class House {
  // Twelve parameters, every caller passes `null` for the ones they don't need.
  constructor(
    walls: number, roof: string, doors: number, windows: number,
    garage: boolean, pool: boolean, garden: boolean, statues: number,
    fence: boolean, solarPanels: boolean, ev: boolean, smart: boolean,
  ) { /* ... */ }
}

// Call site: which `false` corresponds to which feature?
const h = new House(4, 'tile', 2, 6, true, false, true, 0, false, true, false, true);
```

**Correct (steps on a builder; director orchestrates recipes):**

```typescript
/**
 * The Builder interface specifies methods for creating the different parts of
 * the Product objects.
 */
interface Builder {
    producePartA(): void;
    producePartB(): void;
    producePartC(): void;
}

/**
 * The Concrete Builder classes follow the Builder interface and provide
 * specific implementations of the building steps. Your program may have several
 * variations of Builders, implemented differently.
 */
class ConcreteBuilder1 implements Builder {
    private product!: Product1;

    constructor() {
        this.reset();
    }

    public reset(): void {
        this.product = new Product1();
    }

    public producePartA(): void {
        this.product.parts.push('PartA1');
    }

    public producePartB(): void {
        this.product.parts.push('PartB1');
    }

    public producePartC(): void {
        this.product.parts.push('PartC1');
    }

    /**
     * Concrete Builders are supposed to provide their own methods for
     * retrieving results. Various types of builders may create entirely
     * different products, so methods cannot be declared in the base Builder
     * interface (at least in a statically typed language).
     */
    public getProduct(): Product1 {
        const result = this.product;
        this.reset();
        return result;
    }
}

class Product1 {
    public parts: string[] = [];

    public listParts(): void {
        console.log(`Product parts: ${this.parts.join(', ')}\n`);
    }
}

/**
 * The Director is only responsible for executing the building steps in a
 * particular sequence. It is helpful when producing products according to a
 * specific order or configuration. The Director is optional — clients can drive
 * builders directly.
 */
class Director {
    private builder!: Builder;

    public setBuilder(builder: Builder): void {
        this.builder = builder;
    }

    public buildMinimalViableProduct(): void {
        this.builder.producePartA();
    }

    public buildFullFeaturedProduct(): void {
        this.builder.producePartA();
        this.builder.producePartB();
        this.builder.producePartC();
    }
}

function clientCode(director: Director) {
    const builder = new ConcreteBuilder1();
    director.setBuilder(builder);

    console.log('Standard basic product:');
    director.buildMinimalViableProduct();
    builder.getProduct().listParts();

    console.log('Standard full featured product:');
    director.buildFullFeaturedProduct();
    builder.getProduct().listParts();

    // The Builder pattern can be used without a Director class.
    console.log('Custom product:');
    builder.producePartA();
    builder.producePartC();
    builder.getProduct().listParts();
}

const director = new Director();
clientCode(director);
```

**Output:**

```text
Standard basic product:
Product parts: PartA1

Standard full featured product:
Product parts: PartA1, PartB1, PartC1

Custom product:
Product parts: PartA1, PartC1
```

### When to use

- Eliminate the telescoping-constructor anti-pattern
- Create different representations of products using similar construction steps
- Construct Composite trees or other complex objects in stages
- Prevent client code from accessing the product before it is fully assembled

### When NOT to use

- The object has 2-3 parameters with no optional combinations — a plain constructor or factory function suffices
- The product has only one representation and one construction path — Builder is overhead
- TypeScript's named-arguments via object literal already solves the readability problem and you don't need staged construction

### Implementation Steps

1. Identify the discrete construction steps shared by all product representations
2. Declare these steps in a base Builder interface
3. Create a concrete builder per representation, each implementing all steps
4. Add a product-retrieval method on concrete builders (return type may vary by builder)
5. Optionally create a Director to encapsulate construction recipes
6. Client creates a builder (and optionally a director), runs the steps, and retrieves the product

### Pros

- Construct objects incrementally; defer or recurse steps
- Reuse construction code across product variations
- Isolate complex construction logic (Single Responsibility)

### Cons

- Overall code complexity increases due to multiple new classes

### Related Patterns

- **Factory Method** — Builder often evolves from a class with many overloaded constructors
- **Abstract Factory** — Abstract Factory returns a family immediately; Builder builds one product step by step
- **Composite** — Builder is a natural fit for assembling Composite trees
- **Bridge** — director acts as the abstraction; builders as the implementations
- **Singleton** — concrete builders are often Singletons

Reference: [refactoring.guru/design-patterns/builder](https://refactoring.guru/design-patterns/builder)
