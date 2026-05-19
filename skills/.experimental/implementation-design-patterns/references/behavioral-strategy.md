---
title: Use Strategy to Make Algorithms Interchangeable at Runtime
impact: HIGH
impactDescription: eliminates `if (type === 'a') ... else if (type === 'b')` algorithm-selection conditionals scattered through business code, enables runtime swapping of algorithm variants, isolates each algorithm in its own class for independent testing and reuse
tags: behavioral, strategy, runtime-swap, composition-over-conditionals, algorithm-family
---

## Use Strategy to Make Algorithms Interchangeable at Runtime

**Pattern intent:** define a family of algorithms, put each in a separate class, and make them interchangeable through a common interface. The context holds a reference to a strategy and delegates the algorithm execution to it.

### Shapes to recognize

- A class with several methods that branch on `kind`/`type`/`mode` to pick an algorithm
- Multiple sort/route/format/pay/compress variants chosen at runtime by config or user choice
- A class growing massively because every algorithm change adds a branch
- "I want to swap how this works without recompiling or subclassing"

### Problem

A navigation app initially supported car routes, then expanded to walking and public transit, with cyclist and tourist routes planned. Each algorithm addition doubled the main class's size, increased bug risk, and caused merge conflicts during team development.

### Solution

Extract each algorithm variant into a separate class implementing a common Strategy interface. The context holds one strategy reference and delegates work to it. Clients pass the desired strategy in; switching algorithms is one assignment, not a code edit.

**Incorrect (conditional algorithm selection inside the context):**

```typescript
class Navigator {
  route(type: 'car' | 'walking' | 'transit', from: Loc, to: Loc) {
    if (type === 'car')          return /* car logic */ [];
    else if (type === 'walking') return /* walking logic */ [];
    else if (type === 'transit') return /* transit logic */ [];
    // Add 'cyclist'? Edit this method (and every other one with the same shape).
  }
}
```

**Correct (interchangeable strategy objects):**

```typescript
/**
 * The Context defines the interface of interest to clients.
 */
class Context {
    /**
     * @type {Strategy} The Context maintains a reference to one of the Strategy
     * objects. The Context does not know the concrete class of a strategy. It
     * should work with all strategies via the Strategy interface.
     */
    private strategy: Strategy;

    /**
     * Usually, the Context accepts a strategy through the constructor, but also
     * provides a setter to change it at runtime.
     */
    constructor(strategy: Strategy) {
        this.strategy = strategy;
    }

    /**
     * Usually, the Context allows replacing a Strategy object at runtime.
     */
    public setStrategy(strategy: Strategy) {
        this.strategy = strategy;
    }

    /**
     * The Context delegates some work to the Strategy object instead of
     * implementing multiple versions of the algorithm on its own.
     */
    public doSomeBusinessLogic(): void {
        console.log('Context: Sorting data using the strategy (not sure how it\'ll do it)');
        const result = this.strategy.doAlgorithm(['a', 'b', 'c', 'd', 'e']);
        console.log(result.join(','));
    }
}

/**
 * The Strategy interface declares operations common to all supported versions
 * of some algorithm.
 *
 * The Context uses this interface to call the algorithm defined by Concrete
 * Strategies.
 */
interface Strategy {
    doAlgorithm(data: string[]): string[];
}

/**
 * Concrete Strategies implement the algorithm while following the base Strategy
 * interface. The interface makes them interchangeable in the Context.
 */
class ConcreteStrategyA implements Strategy {
    public doAlgorithm(data: string[]): string[] {
        return data.sort();
    }
}

class ConcreteStrategyB implements Strategy {
    public doAlgorithm(data: string[]): string[] {
        return data.reverse();
    }
}

/**
 * The client code picks a concrete strategy and passes it to the context. The
 * client should be aware of the differences between strategies in order to make
 * the right choice.
 */
const context = new Context(new ConcreteStrategyA());
console.log('Client: Strategy is set to normal sorting.');
context.doSomeBusinessLogic();

console.log('');

console.log('Client: Strategy is set to reverse sorting.');
context.setStrategy(new ConcreteStrategyB());
context.doSomeBusinessLogic();
```

**Output:**

```text
Client: Strategy is set to normal sorting.
Context: Sorting data using the strategy (not sure how it'll do it)
a,b,c,d,e

Client: Strategy is set to reverse sorting.
Context: Sorting data using the strategy (not sure how it'll do it)
e,d,c,b,a
```

### When to use

- You need different variants of an algorithm within an object with runtime switching
- You have similar classes that differ only in their execution behavior
- You want to separate business logic from algorithm implementation details
- A class contains massive conditionals that pick an algorithm variant

### When NOT to use

- The algorithm is small, stable, and rarely changes — a function suffices
- Algorithms must be selected at compile time and never swap at runtime — **Template Method** with inheritance is enough
- In modern TypeScript, the strategy interface is often just a function type: `type Strategy = (data: string[]) => string[]`. Pass it directly without wrapping in a class.

### Implementation Steps

1. Identify the algorithm prone to frequent change in the context
2. Declare a strategy interface common to all algorithm variants
3. Extract each algorithm into a class implementing the interface
4. Add a field storing a strategy reference and a setter on the context
5. Clients associate the context with a suitable strategy

### Pros

- Swap algorithms at runtime
- Isolate algorithm implementation details from usage code
- Replace inheritance with composition
- Open/Closed Principle compliance for adding new strategies

### Cons

- Unnecessary complexity for few, stable algorithms
- Clients must understand strategy differences to choose the right one
- In functional languages or modern TS, anonymous functions provide a simpler alternative

### Related Patterns

- **State** — same composition shape; State objects know each other and trigger transitions on the context; Strategy objects are independent
- **Bridge** — also composition-based, but Bridge splits abstraction from implementation along two orthogonal axes
- **Template Method** — varies parts of an algorithm via inheritance (compile-time); Strategy varies the whole algorithm via composition (runtime)
- **Decorator** — Decorator changes appearance/behavior layer; Strategy changes the algorithm

Reference: [refactoring.guru/design-patterns/strategy](https://refactoring.guru/design-patterns/strategy)
