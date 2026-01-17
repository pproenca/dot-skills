---
title: Replace Conditional with Polymorphism
impact: HIGH
impactDescription: eliminates repeated switch statements and enables Open-Closed Principle
tags: cond, polymorphism, switch-statement, strategy-pattern
---

## Replace Conditional with Polymorphism

When the same switch/if-else on type appears in multiple places, replace it with polymorphism. New types can be added without modifying existing code.

**Incorrect (repeated type-based conditionals):**

```typescript
type ShapeType = 'circle' | 'rectangle' | 'triangle'

interface Shape {
  type: ShapeType
  radius?: number
  width?: number
  height?: number
  base?: number
}

function calculateArea(shape: Shape): number {
  switch (shape.type) {
    case 'circle':
      return Math.PI * shape.radius! ** 2
    case 'rectangle':
      return shape.width! * shape.height!
    case 'triangle':
      return (shape.base! * shape.height!) / 2
    default:
      throw new Error(`Unknown shape: ${shape.type}`)
  }
}

function calculatePerimeter(shape: Shape): number {
  switch (shape.type) {  // Same switch repeated
    case 'circle':
      return 2 * Math.PI * shape.radius!
    case 'rectangle':
      return 2 * (shape.width! + shape.height!)
    case 'triangle':
      // Complex calculation...
  }
}
// Adding a new shape requires modifying EVERY function
```

**Correct (polymorphic solution):**

```typescript
interface Shape {
  calculateArea(): number
  calculatePerimeter(): number
}

class Circle implements Shape {
  constructor(private radius: number) {}

  calculateArea(): number {
    return Math.PI * this.radius ** 2
  }

  calculatePerimeter(): number {
    return 2 * Math.PI * this.radius
  }
}

class Rectangle implements Shape {
  constructor(private width: number, private height: number) {}

  calculateArea(): number {
    return this.width * this.height
  }

  calculatePerimeter(): number {
    return 2 * (this.width + this.height)
  }
}

// Adding a new shape only requires a new class
class Pentagon implements Shape {
  constructor(private sideLength: number) {}

  calculateArea(): number {
    return (Math.sqrt(5 * (5 + 2 * Math.sqrt(5))) / 4) * this.sideLength ** 2
  }

  calculatePerimeter(): number {
    return 5 * this.sideLength
  }
}
```

**When to use polymorphism:**
- Same conditional on type appears 3+ times
- New types are likely to be added
- Behavior differs significantly between types

Reference: [Replace Conditional with Polymorphism](https://refactoring.com/catalog/replaceConditionalWithPolymorphism.html)
