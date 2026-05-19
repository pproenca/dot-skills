---
title: Use Flyweight to Share Common State Across Many Objects
impact: LOW-MEDIUM
impactDescription: drastically reduces memory footprint when spawning millions of similar objects (game particles, cell sprites, text glyphs) by sharing immutable intrinsic state and passing variable extrinsic state per call
tags: structural, flyweight, memory-optimization, shared-state, intrinsic-extrinsic
---

## Use Flyweight to Share Common State Across Many Objects

**Pattern intent:** fit more objects into available RAM by sharing common state between multiple instances instead of duplicating it. Intrinsic (shared, immutable) state lives in the flyweight; extrinsic (per-instance) state is passed in as parameters.

### Shapes to recognize

- Spawning a huge number of similar objects (game particles, characters in a typesetting engine, cells in a grid, leaves in a forest) and running out of memory
- Profile shows most fields per object are the same — color, sprite, mesh, font glyph
- An object pool that already deduplicates instances by some key — that's a Flyweight factory
- "I have a million bullets and they're all red M4-style; storing the sprite per bullet is wasteful"

### Problem

A particle system crashes on lower-spec devices: each particle holds substantial data (color, sprite, mesh), and millions of identical copies exhaust RAM.

### Solution

Split state into intrinsic (immutable, shared across many particles — sprite, color, mesh) and extrinsic (unique per particle — position, velocity). The intrinsic state becomes a shared Flyweight object retrieved through a factory that deduplicates by key. The extrinsic state is passed into Flyweight methods at call time.

**Incorrect (every particle carries its own copy of intrinsic state):**

```typescript
class Particle {
  constructor(
    public x: number,
    public y: number,
    public sprite: ImageBitmap,   // big — duplicated across millions of bullets
    public color: string,
    public mesh: Float32Array,
  ) {}
}
// 5,000,000 particles × (sprite + mesh) — memory blown
```

**Correct (intrinsic state shared via factory, extrinsic state passed in):**

```typescript
/**
 * The Flyweight stores a common portion of the state (also called intrinsic
 * state) that belongs to multiple real business entities. The Flyweight accepts
 * the rest of the state (extrinsic state, unique for each entity) via its
 * method parameters.
 */
class Flyweight {
    private sharedState: any;

    constructor(sharedState: any) {
        this.sharedState = sharedState;
    }

    public operation(uniqueState): void {
        const s = JSON.stringify(this.sharedState);
        const u = JSON.stringify(uniqueState);
        console.log(`Flyweight: Displaying shared (${s}) and unique (${u}) state.`);
    }
}

/**
 * The Flyweight Factory creates and manages the Flyweight objects. It ensures
 * that flyweights are shared correctly. When the client requests a flyweight,
 * the factory either returns an existing instance or creates a new one, if it
 * doesn't exist yet.
 */
class FlyweightFactory {
    private flyweights: {[key: string]: Flyweight} = <any>{};

    constructor(initialFlyweights: string[][]) {
        for (const state of initialFlyweights) {
            this.flyweights[this.getKey(state)] = new Flyweight(state);
        }
    }

    private getKey(state: string[]): string {
        return state.join('_');
    }

    public getFlyweight(sharedState: string[]): Flyweight {
        const key = this.getKey(sharedState);

        if (!(key in this.flyweights)) {
            console.log('FlyweightFactory: Can\'t find a flyweight, creating new one.');
            this.flyweights[key] = new Flyweight(sharedState);
        } else {
            console.log('FlyweightFactory: Reusing existing flyweight.');
        }

        return this.flyweights[key];
    }

    public listFlyweights(): void {
        const count = Object.keys(this.flyweights).length;
        console.log(`\nFlyweightFactory: I have ${count} flyweights:`);
        for (const key in this.flyweights) {
            console.log(key);
        }
    }
}

const factory = new FlyweightFactory([
    ['Chevrolet', 'Camaro2018', 'pink'],
    ['Mercedes Benz', 'C300', 'black'],
    ['Mercedes Benz', 'C500', 'red'],
    ['BMW', 'M5', 'red'],
    ['BMW', 'X6', 'white'],
]);
factory.listFlyweights();

function addCarToPoliceDatabase(
    ff: FlyweightFactory, plates: string, owner: string,
    brand: string, model: string, color: string,
) {
    console.log('\nClient: Adding a car to database.');
    const flyweight = ff.getFlyweight([brand, model, color]);

    // The client code either stores or calculates extrinsic state and passes it
    // to the flyweight's methods.
    flyweight.operation([plates, owner]);
}

addCarToPoliceDatabase(factory, 'CL234IR', 'James Doe', 'BMW', 'M5', 'red');
addCarToPoliceDatabase(factory, 'CL234IR', 'James Doe', 'BMW', 'X1', 'red');

factory.listFlyweights();
```

**Output:**

```text
FlyweightFactory: I have 5 flyweights:
Chevrolet_Camaro2018_pink
Mercedes Benz_C300_black
Mercedes Benz_C500_red
BMW_M5_red
BMW_X6_white

Client: Adding a car to database.
FlyweightFactory: Reusing existing flyweight.
Flyweight: Displaying shared (["BMW","M5","red"]) and unique (["CL234IR","James Doe"]) state.

Client: Adding a car to database.
FlyweightFactory: Can't find a flyweight, creating new one.
Flyweight: Displaying shared (["BMW","X1","red"]) and unique (["CL234IR","James Doe"]) state.

FlyweightFactory: I have 6 flyweights:
Chevrolet_Camaro2018_pink
Mercedes Benz_C300_black
Mercedes Benz_C500_red
BMW_M5_red
BMW_X6_white
BMW_X1_red
```

### When to use

- An application spawns a huge number of similar objects
- This drains all available RAM on a target device
- The objects contain duplicate state that can be extracted and shared

### When NOT to use

- Object count is modest — Flyweight buys nothing
- Memory is not the constraint — CPU may rise as extrinsic state must be recomputed or threaded through every call
- The intrinsic state isn't truly immutable — sharing mutable state causes subtle aliasing bugs

### Implementation Steps

1. Divide each class's fields into intrinsic (immutable, duplicated) and extrinsic (contextual, unique)
2. Keep intrinsic fields immutable; initialize only through the constructor
3. Modify methods that use extrinsic fields to accept them as parameters
4. Create a factory class that manages a pool of flyweights, returning an existing one or creating a new one
5. Store or calculate extrinsic state in client code or separate context classes

### Pros

- Significant RAM savings when managing massive quantities of similar objects

### Cons

- CPU may rise if extrinsic state must be recomputed per call
- Code complexity increases substantially — team comprehension suffers

### Related Patterns

- **Composite** — leaf nodes of a Composite tree are often Flyweights to save memory
- **Facade** — Facade creates one object representing a subsystem; Flyweight creates many small ones
- **Singleton** — different goals: Singleton allows one instance; Flyweight allows many shared instances per intrinsic key. Flyweights are immutable; Singletons usually aren't.

Reference: [refactoring.guru/design-patterns/flyweight](https://refactoring.guru/design-patterns/flyweight)
