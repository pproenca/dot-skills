---
title: Use Iterator to Traverse Collections Without Exposing Their Internals
impact: HIGH
impactDescription: hides collection representation from callers (list, tree, graph, stream all look the same), enables multiple independent traversals over the same collection, eliminates duplicated traversal code throughout the application
tags: behavioral, iterator, traversal, encapsulation, sequence
---

## Use Iterator to Traverse Collections Without Exposing Their Internals

**Pattern intent:** traverse elements of a collection without exposing the underlying representation (list, stack, tree, graph). Iterators encapsulate traversal logic and state; multiple iterators can walk the same collection independently.

### Shapes to recognize

- Two collections with different storage shapes — callers must know `array[i]` vs `tree.walk()` vs `graph.bfs()`
- Need to iterate the same collection multiple times in parallel, each from a different position
- Need different orders over the same data — forward, reverse, sorted, filtered
- "I want to support `for...of` over my custom collection"

### Problem

Collections need sequential access regardless of internal structure. Adding traversal algorithms directly to collection classes obscures their primary responsibility and forces clients to know which collection they're dealing with.

### Solution

Extract traversal behavior into separate iterator objects that hold the current position and walk the collection. Standard interfaces let clients consume any collection the same way. The collection exposes a factory method for iterators; the iterator does the rest.

**Incorrect (caller knows about every collection's shape):**

```typescript
function printAll(words: WordsCollection) {
  // Caller dives into internals — moving to a tree-backed store breaks this
  for (let i = 0; i < words.items.length; i++) {
    console.log(words.items[i]);
  }
}
```

**Correct (collection returns an iterator; caller is structure-agnostic):**

```typescript
/**
 * Iterator Design Pattern
 *
 * Intent: Lets you traverse elements of a collection without exposing its
 * underlying representation (list, stack, tree, etc.).
 */

interface Iterator<T> {
    // Return the current element.
    current(): T;

    // Return the current element and move forward to next element.
    next(): T;

    // Return the key of the current element.
    key(): number;

    // Checks if current position is valid.
    valid(): boolean;

    // Rewind the Iterator to the first element.
    rewind(): void;
}

interface Aggregator {
    // Retrieve an external iterator.
    getIterator(): Iterator<string>;
}

/**
 * Concrete Iterators implement various traversal algorithms. These classes
 * store the current traversal position at all times.
 */
class AlphabeticalOrderIterator implements Iterator<string> {
    private collection: WordsCollection;

    private position: number = 0;

    private reverse: boolean = false;

    constructor(collection: WordsCollection, reverse: boolean = false) {
        this.collection = collection;
        this.reverse = reverse;

        if (reverse) {
            this.position = collection.getCount() - 1;
        }
    }

    public rewind() {
        this.position = this.reverse ?
            this.collection.getCount() - 1 :
            0;
    }

    public current(): string {
        return this.collection.getItems()[this.position];
    }

    public key(): number {
        return this.position;
    }

    public next(): string {
        const item = this.collection.getItems()[this.position];
        this.position += this.reverse ? -1 : 1;
        return item;
    }

    public valid(): boolean {
        if (this.reverse) {
            return this.position >= 0;
        }

        return this.position < this.collection.getCount();
    }
}

/**
 * Concrete Collections provide one or several methods for retrieving fresh
 * iterator instances, compatible with the collection class.
 */
class WordsCollection implements Aggregator {
    private items: string[] = [];

    public getItems(): string[] {
        return this.items;
    }

    public getCount(): number {
        return this.items.length;
    }

    public addItem(item: string): void {
        this.items.push(item);
    }

    public getIterator(): Iterator<string> {
        return new AlphabeticalOrderIterator(this);
    }

    public getReverseIterator(): Iterator<string> {
        return new AlphabeticalOrderIterator(this, true);
    }
}

const collection = new WordsCollection();
collection.addItem('First');
collection.addItem('Second');
collection.addItem('Third');

const iterator = collection.getIterator();

console.log('Straight traversal:');
while (iterator.valid()) {
    console.log(iterator.next());
}

console.log('');
console.log('Reverse traversal:');
const reverseIterator = collection.getReverseIterator();
while (reverseIterator.valid()) {
    console.log(reverseIterator.next());
}
```

**Output:**

```text
Straight traversal:
First
Second
Third

Reverse traversal:
Third
Second
First
```

### When to use

- Hide complexity of traversing complex data structures
- Reduce duplication of traversal code throughout the application
- Allow client code to traverse different data structures when types are unknown beforehand
- Enable parallel iteration with independent state

### When NOT to use

- The collection is a plain array — `for...of` or `.forEach()` is built into the language
- Only one traversal exists — exposing it as a method is simpler
- In modern TypeScript, implement `Symbol.iterator` on the collection rather than building a custom interface — it integrates with `for...of`, spread, destructuring, and generators

### Implementation Steps

1. Declare the iterator interface (`next`, `valid`, `current`, `rewind`)
2. Declare the collection interface with a method that returns an iterator
3. Implement concrete iterators bound to specific collection instances
4. Implement the collection to provide iterator factory methods
5. Replace explicit collection traversal in clients with iterator usage

### Pros

- Single Responsibility: traversal extracted from collection
- Open/Closed: add new collections and iterators without changing client code
- Parallel iteration with independent state per iterator
- Iteration can be delayed and resumed

### Cons

- May be excessive for simple collections
- Sometimes less efficient than direct element access for specialized collections

### Related Patterns

- **Composite** — Iterators traverse Composite trees uniformly
- **Factory Method** — collection subclasses return iterators via a factory method
- **Memento** — capture and restore iteration state
- **Visitor** — execute operations on each element during iteration

Reference: [refactoring.guru/design-patterns/iterator](https://refactoring.guru/design-patterns/iterator)
