---
title: Understand Data/Object Anti-Symmetry
impact: MEDIUM-HIGH
impactDescription: prevents 2× effort when requirements change
tags: obj, asymmetry, procedural, polymorphism
---

## Understand Data/Object Anti-Symmetry

Objects and data structures are opposites. Objects hide data and expose behavior; data structures expose data and have no behavior. Choose based on what kind of changes you anticipate.

**Incorrect (wrong approach for frequent type additions):**

```java
// Procedural approach - adding Triangle requires modifying EVERY function
public class Square { public double side; }
public class Circle { public double radius; }

public class Geometry {
    public double area(Object shape) {
        if (shape instanceof Square) {
            Square s = (Square) shape;
            return s.side * s.side;
        } else if (shape instanceof Circle) {
            Circle c = (Circle) shape;
            return Math.PI * c.radius * c.radius;
        }
        // Must add Triangle case here AND in perimeter() AND in draw()...
        throw new NoSuchShapeException();
    }
}
```

**Correct (polymorphic approach for frequent type additions):**

```java
// Object approach - adding Triangle only requires one new class
public interface Shape {
    double area();
}

public class Square implements Shape {
    private double side;

    public double area() {
        return side * side;
    }
}

public class Circle implements Shape {
    private double radius;

    public double area() {
        return Math.PI * radius * radius;
    }
}

// Adding Triangle is easy - just add one class
public class Triangle implements Shape {
    private double base, height;

    public double area() {
        return 0.5 * base * height;
    }
}
```

**Choose based on anticipated changes:**
- Adding new functions often? Use data structures (procedural)
- Adding new types often? Use objects (polymorphic)

Reference: [Clean Code, Chapter 6: Objects and Data Structures](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
