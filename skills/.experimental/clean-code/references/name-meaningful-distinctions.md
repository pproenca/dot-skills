---
title: Make Meaningful Distinctions
impact: CRITICAL
impactDescription: eliminates ambiguity between similar concepts
tags: name, distinction, noise-words, clarity
---

## Make Meaningful Distinctions

If names must be different, then they should also mean something different. Avoid number-series naming and noise words that add no information.

**Incorrect (indistinguishable names):**

```java
// Number series - meaningless distinction
public static void copyChars(char[] a1, char[] a2) {
    for (int i = 0; i < a1.length; i++) {
        a2[i] = a1[i];
    }
}

// Noise words - what's the difference?
class Product {}
class ProductInfo {}
class ProductData {}

// Redundant prefixes
String nameString;
Customer customerObject;
```

**Correct (meaningful distinctions):**

```java
// Descriptive parameter names
public static void copyChars(char[] source, char[] destination) {
    for (int i = 0; i < source.length; i++) {
        destination[i] = source[i];
    }
}

// If distinctions exist, name them
class Product {}
class ProductDetails {}       // Shows additional information
class ProductInventory {}     // Stock and availability

// No redundant type encoding
String name;
Customer customer;
```

If you cannot distinguish what `ProductInfo` offers that `Product` does not, the names are noise.

Reference: [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
