---
title: Hide Data Behind Abstractions
impact: MEDIUM-HIGH
impactDescription: enables implementation changes without ripple effects
tags: obj, abstraction, encapsulation, data-hiding
---

## Hide Data Behind Abstractions

Objects hide their data behind abstractions and expose functions that operate on that data. Data structures expose their data and have no meaningful functions. Do not mix these concepts.

**Incorrect (exposing implementation):**

```java
// Exposes internal representation - clients depend on Cartesian coordinates
public class Point {
    public double x;
    public double y;
}

// Using it forces clients to know the implementation
double distance = Math.sqrt(point.x * point.x + point.y * point.y);
```

**Correct (hiding behind abstraction):**

```java
// Hides representation - could be Cartesian, polar, or something else
public interface Point {
    double getX();
    double getY();
    void setCartesian(double x, double y);
    double getR();
    double getTheta();
    void setPolar(double r, double theta);
}

// Clients work with the abstraction
double distance = point.getR();  // Works regardless of internal representation
```

**Key insight:** The abstraction is not just about using getters/setters. It is about hiding the form of the data and exposing operations that work with the abstract concept.

Reference: [Clean Code, Chapter 6: Objects and Data Structures](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
