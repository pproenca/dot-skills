---
title: Use Composite to Treat Trees and Leaves Uniformly
impact: HIGH
impactDescription: eliminates `instanceof` and type-discrimination throughout traversal code, enables recursive operations across object trees through a single interface, lets clients work with arbitrarily nested structures without knowing the nesting level
tags: structural, composite, tree-structure, recursion, polymorphism
---

## Use Composite to Treat Trees and Leaves Uniformly

**Pattern intent:** compose objects into tree structures, then operate on them as if individual objects. Leaves and containers implement the same interface so client code traverses recursively without distinguishing them.

### Shapes to recognize

- A tree-shaped domain: file systems, folders/files, organization charts, expression ASTs, UI component trees, nested orders/line-items
- Code peppered with `instanceof` checks to handle "is this a leaf or a container?"
- Two parallel APIs — one for primitives, one for containers — that callers must switch between
- "I need to compute a total across a nested structure"

### Problem

A box contains products and smaller boxes that contain more products and boxes. Computing totals requires knowing concrete classes and nesting levels in advance. Direct approaches force `instanceof` discrimination scattered through traversal code.

### Solution

Declare a common Component interface for leaves and containers. Leaves do the actual work. Containers delegate to children recursively, then aggregate results. Clients call the interface and let polymorphism handle the rest.

**Incorrect (separate APIs, type-checks everywhere):**

```typescript
class Product { constructor(public price: number) {} }
class Box     { public items: (Product | Box)[] = []; }

function totalPrice(node: Product | Box): number {
  // Every traversal must discriminate — instanceof leaks the structure
  if (node instanceof Product) return node.price;
  return node.items.reduce((sum, item) => sum + totalPrice(item), 0);
}
```

**Correct (one interface, recursion is built in):**

```typescript
/**
 * The base Component class declares common operations for both simple and
 * complex objects of a composition.
 */
abstract class Component {
    protected parent!: Component | null;

    public setParent(parent: Component | null) {
        this.parent = parent;
    }

    public getParent(): Component | null {
        return this.parent;
    }

    /**
     * Defining child-management operations on the base Component class lets the
     * client code stay structure-agnostic during tree assembly. The trade-off
     * is that these methods are empty for leaf components.
     */
    public add(component: Component): void { }

    public remove(component: Component): void { }

    /**
     * You can provide a method that lets the client code figure out whether a
     * component can bear children.
     */
    public isComposite(): boolean {
        return false;
    }

    public abstract operation(): string;
}

/**
 * The Leaf class represents the end objects of a composition. A leaf can't have
 * any children.
 */
class Leaf extends Component {
    public operation(): string {
        return 'Leaf';
    }
}

/**
 * The Composite class represents the complex components that may have children.
 */
class Composite extends Component {
    protected children: Component[] = [];

    public add(component: Component): void {
        this.children.push(component);
        component.setParent(this);
    }

    public remove(component: Component): void {
        const componentIndex = this.children.indexOf(component);
        this.children.splice(componentIndex, 1);
        component.setParent(null);
    }

    public isComposite(): boolean {
        return true;
    }

    /**
     * The Composite executes its primary logic in a particular way. It
     * traverses recursively through all its children, collecting and summing
     * their results.
     */
    public operation(): string {
        const results = [];
        for (const child of this.children) {
            results.push(child.operation());
        }

        return `Branch(${results.join('+')})`;
    }
}

function clientCode(component: Component) {
    console.log(`RESULT: ${component.operation()}`);
}

const simple = new Leaf();
console.log('Client: I\'ve got a simple component:');
clientCode(simple);
console.log('');

const tree = new Composite();
const branch1 = new Composite();
branch1.add(new Leaf());
branch1.add(new Leaf());
const branch2 = new Composite();
branch2.add(new Leaf());
tree.add(branch1);
tree.add(branch2);
console.log('Client: Now I\'ve got a composite tree:');
clientCode(tree);
console.log('');

function clientCode2(component1: Component, component2: Component) {
    if (component1.isComposite()) {
        component1.add(component2);
    }
    console.log(`RESULT: ${component1.operation()}`);
}

console.log('Client: I don\'t need to check the components classes even when managing the tree:');
clientCode2(tree, simple);
```

**Output:**

```text
Client: I've got a simple component:
RESULT: Leaf

Client: Now I've got a composite tree:
RESULT: Branch(Branch(Leaf+Leaf)+Branch(Leaf))

Client: I don't need to check the components classes even when managing the tree:
RESULT: Branch(Branch(Leaf+Leaf)+Branch(Leaf)+Leaf)
```

### When to use

- The domain is naturally tree-shaped — file systems, expression trees, UI hierarchies, org charts
- Clients should treat leaves and containers uniformly
- You want recursive operations across the tree without external type-checking

### When NOT to use

- The structure isn't actually a tree — flat collections don't need Composite
- Leaves and containers diverge so much that forcing a common interface dilutes both
- Operations on the tree happen at the root only — direct recursion suffices
- When the leaf and container behaviors are too different to share an interface without ceremony

### Implementation Steps

1. Confirm the model is a tree; decompose into elements (leaves) and containers (composites)
2. Declare the Component interface with operations applicable to both
3. Create Leaf classes for simple elements (multiple leaf types allowed)
4. Create a Composite class with a child array; implement interface methods to delegate to children
5. Define add/remove methods for children (in Composite, or in the base Component if you want a uniform child API)

### Pros

- Handle complex tree structures conveniently using polymorphism and recursion
- Open/Closed Principle: add new element types without breaking existing code
- Clients work with the abstract Component interface — concrete tree shape is hidden

### Cons

- Difficult to provide a common interface when leaves and containers differ significantly
- May overgeneralize the Component interface, reducing clarity

### Related Patterns

- **Builder** — construct complex Composite trees in stages
- **Chain of Responsibility** — leaves can pass requests up the parent chain
- **Iterator** — traverse Composite trees with a dedicated iterator
- **Visitor** — execute operations across an entire Composite tree
- **Flyweight** — share leaf nodes to conserve memory in deep trees
- **Decorator** — similar wrapping shape, but Decorator has one child and adds behavior; Composite has many children and aggregates

Reference: [refactoring.guru/design-patterns/composite](https://refactoring.guru/design-patterns/composite)
