---
title: Prefer Composition Over Inheritance
impact: MEDIUM-HIGH
impactDescription: enables flexible behavior combination without class explosion
tags: pattern, composition, inheritance, flexibility
---

## Prefer Composition Over Inheritance

Inheritance creates tight coupling and can lead to fragile base class problems. Compose objects by combining behaviors at runtime.

**Incorrect (inheritance hierarchy for behavior combinations):**

```typescript
class Animal {
  eat(): void { /* ... */ }
}

class FlyingAnimal extends Animal {
  fly(): void { /* ... */ }
}

class SwimmingAnimal extends Animal {
  swim(): void { /* ... */ }
}

// Problem: Duck can fly AND swim - which class to extend?
class FlyingSwimmingAnimal extends FlyingAnimal {
  swim(): void { /* ... */ }  // Duplicated from SwimmingAnimal
}

class Duck extends FlyingSwimmingAnimal {}

// Adding walking, running, climbing leads to class explosion:
// FlyingWalkingAnimal, SwimmingWalkingAnimal, FlyingSwimmingWalkingAnimal...
```

**Correct (composition of behaviors):**

```typescript
interface Behavior {
  perform(): void
}

class FlyingBehavior implements Behavior {
  perform(): void {
    console.log('Flying through the air')
  }
}

class SwimmingBehavior implements Behavior {
  perform(): void {
    console.log('Swimming in water')
  }
}

class WalkingBehavior implements Behavior {
  perform(): void {
    console.log('Walking on land')
  }
}

class Animal {
  private behaviors: Behavior[] = []

  addBehavior(behavior: Behavior): void {
    this.behaviors.push(behavior)
  }

  performBehaviors(): void {
    this.behaviors.forEach(b => b.perform())
  }
}

// Duck composes the behaviors it needs
const duck = new Animal()
duck.addBehavior(new FlyingBehavior())
duck.addBehavior(new SwimmingBehavior())
duck.addBehavior(new WalkingBehavior())

// Penguin has different combination
const penguin = new Animal()
penguin.addBehavior(new SwimmingBehavior())
penguin.addBehavior(new WalkingBehavior())

// Behaviors can even be changed at runtime
```

**When inheritance is appropriate:**
- True "is-a" relationship with LSP compliance
- Behavior rarely changes between subclasses
- Framework requires it (React class components, etc.)

Reference: [Composition Over Inheritance](https://en.wikipedia.org/wiki/Composition_over_inheritance)
