---
title: Avoid Encodings in Names
impact: HIGH
impactDescription: reduces mental translation burden
tags: name, encoding, hungarian, prefixes
---

## Avoid Encodings in Names

Encoding type or scope information into names adds an extra burden of deciphering. Modern IDEs make Hungarian Notation and member prefixes unnecessary.

**Incorrect (encoded type and scope):**

```java
// Hungarian Notation - type encoded in name
String strName;
int iAge;
boolean bIsActive;
PhoneNumber phoneString;  // Type changed but name wasn't updated!

// Member prefixes
public class Part {
    private String m_dsc;  // Member description

    void setDescription(String dsc) {
        m_dsc = dsc;
    }
}

// Interface prefix
public interface IShapeFactory {}
```

**Correct (no encodings):**

```java
// Let the type system handle types
String name;
int age;
boolean isActive;
PhoneNumber phone;

// No member prefixes - IDE highlights members
public class Part {
    private String description;

    void setDescription(String description) {
        this.description = description;
    }
}

// Drop the interface prefix — callers use ShapeFactory, not IShapeFactory
public interface ShapeFactory {}

// Name implementations by what distinguishes them
public class JsonShapeFactory implements ShapeFactory {}
public class SvgShapeFactory implements ShapeFactory {}

// If only one implementation exists, consider whether you need the interface at all
```

Readers learn to ignore prefixes. You end up seeing only the meaningful part of the name.

**Note:** `ShapeFactoryImpl` is a lesser evil than `IShapeFactory`, but `Impl` is still an encoding. When possible, name implementations by their distinguishing characteristic (protocol, storage mechanism, algorithm).

Reference: [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
