---
title: Use Adapter to Make Incompatible Interfaces Cooperate
impact: HIGH
impactDescription: enables reusing existing classes whose interface doesn't match what callers expect, eliminates ad-hoc conversion code scattered across call sites, isolates third-party API translation in one class
tags: structural, adapter, interface-translation, integration, wrapper
---

## Use Adapter to Make Incompatible Interfaces Cooperate

**Pattern intent:** translate the interface of one class into another that clients expect. The adapter implements the target interface and delegates to the adaptee internally, performing whatever conversion is needed.

### Shapes to recognize

- A third-party library whose API doesn't match your code's expectations — XML vs JSON, callback vs Promise, snake_case vs camelCase
- Conversion code (parsing, mapping, format normalization) duplicated at every call site
- A legacy class you can't modify but still need to use
- Integration boundaries: "I need to feed data from System A into System B"

### Problem

An app downloads stock data in XML, but a third-party analytics library only accepts JSON. You can't modify the library, and littering conversion code at every call site is error-prone and unmaintainable.

### Solution

Create a class implementing the target interface clients expect. Internally hold the adaptee object and translate each call — convert arguments, invoke the adaptee, convert the result. Clients deal only with the target interface.

**Incorrect (translation duplicated at every call site):**

```typescript
class XmlStockFeed {
  getQuoteXml(symbol: string): string {
    return `<quote symbol="${symbol}"><price>120</price></quote>`;
  }
}

class JsonAnalytics {
  analyze(payload: { symbol: string; price: number }) { /* ... */ }
}

// Every caller has to know about both shapes and do its own conversion:
const feed = new XmlStockFeed();
const analytics = new JsonAnalytics();
const xml = feed.getQuoteXml('ACME');
const symbolMatch = xml.match(/symbol="([^"]+)"/);
const priceMatch = xml.match(/<price>(\d+)<\/price>/);
analytics.analyze({
  symbol: symbolMatch![1],
  price: Number(priceMatch![1]),
});
```

**Correct (one adapter, callers don't know about XML):**

```typescript
/**
 * The Target defines the domain-specific interface used by the client code.
 */
class Target {
    public request(): string {
        return 'Target: The default target\'s behavior.';
    }
}

/**
 * The Adaptee contains some useful behavior, but its interface is incompatible
 * with the existing client code. The Adaptee needs some adaptation before the
 * client code can use it.
 */
class Adaptee {
    public specificRequest(): string {
        return '.eetpadA eht fo roivaheb laicepS';
    }
}

/**
 * The Adapter makes the Adaptee's interface compatible with the Target's
 * interface.
 */
class Adapter extends Target {
    private adaptee: Adaptee;

    constructor(adaptee: Adaptee) {
        super();
        this.adaptee = adaptee;
    }

    public request(): string {
        const result = this.adaptee.specificRequest().split('').reverse().join('');
        return `Adapter: (TRANSLATED) ${result}`;
    }
}

/**
 * The client code supports all classes that follow the Target interface.
 */
function clientCode(target: Target) {
    console.log(target.request());
}

console.log('Client: I can work just fine with the Target objects:');
const target = new Target();
clientCode(target);

console.log('');

const adaptee = new Adaptee();
console.log('Client: The Adaptee class has a weird interface. See, I don\'t understand it:');
console.log(`Adaptee: ${adaptee.specificRequest()}`);

console.log('');

console.log('Client: But I can work with it via the Adapter:');
const adapter = new Adapter(adaptee);
clientCode(adapter);
```

**Output:**

```text
Client: I can work just fine with the Target objects:
Target: The default target's behavior.

Client: The Adaptee class has a weird interface. See, I don't understand it:
Adaptee: .eetpadA eht fo roivaheb laicepS

Client: But I can work with it via the Adapter:
Adapter: (TRANSLATED) Special behavior of the Adaptee.
```

### When to use

- You want to use an existing class but its interface doesn't match
- You need a translation layer between your code and a legacy or third-party class
- You're reusing several subclasses that lack common functionality — adapters avoid duplicating that code across new child classes

### When NOT to use

- You designed both sides of the interface — fix the interface directly instead of adapting
- The adaptation requires substantial logic (more than format/shape conversion) — that's a service, not an adapter
- A simple inline conversion at a single call site doesn't justify a new class

### Implementation Steps

1. Identify the two classes with incompatible interfaces
2. Declare the client (target) interface
3. Create the adapter class implementing the target interface
4. Add a field referencing the adaptee
5. Implement target methods by delegating to the adaptee with conversion
6. Have clients interact only via the target interface

### Pros

- Separates interface conversion from business logic (Single Responsibility)
- Enables adding new adapters without breaking existing code (Open/Closed)
- Lets you reuse existing code by isolating the conversion

### Cons

- Overall code complexity increases with new interfaces and classes
- Sometimes simpler to modify the service class directly when you own it

### Related Patterns

- **Bridge** — designed upfront to split abstraction from implementation; Adapter is typically retrofitted to existing classes
- **Decorator** — same wrapping shape, but Decorator keeps the same interface and adds behavior, while Adapter changes the interface
- **Proxy** — keeps the same interface and controls access; Adapter changes the interface
- **Facade** — defines a *new* interface over a *subsystem*; Adapter wraps a *single object* to match an *existing* interface

Reference: [refactoring.guru/design-patterns/adapter](https://refactoring.guru/design-patterns/adapter)
