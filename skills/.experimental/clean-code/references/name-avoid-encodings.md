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

// Prefer encoding implementation, not interface
public interface ShapeFactory {}
public class ShapeFactoryImpl implements ShapeFactory {}
```

Readers learn to ignore prefixes. You end up seeing only the meaningful part of the name.

Reference: [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
