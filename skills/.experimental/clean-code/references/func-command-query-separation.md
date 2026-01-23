---
title: Separate Commands from Queries
impact: HIGH
impactDescription: eliminates ambiguous function behavior
tags: func, cqs, command, query, separation
---

## Separate Commands from Queries

Functions should either do something or answer something, but not both. Either your function changes the state of an object, or it returns information about that object.

**Incorrect (command and query mixed):**

```java
// Does this set the attribute and return success?
// Or check if attribute exists?
public boolean set(String attribute, String value) {
    // ... sets attribute and returns true if it was set
}

// Confusing usage
if (set("username", "bob")) {
    // Was username set, or did it already exist?
}
```

**Correct (separated command and query):**

```java
// Query - returns information
public boolean attributeExists(String attribute) {
    return attributes.containsKey(attribute);
}

// Command - changes state
public void setAttribute(String attribute, String value) {
    attributes.put(attribute, value);
}

// Clear usage
if (!attributeExists("username")) {
    setAttribute("username", "bob");
}
```

**Alternative (return new state for immutable design):**

```java
// For immutable patterns, returning new state is acceptable
public Settings withAttribute(String attribute, String value) {
    return new Settings(this.attributes.plus(attribute, value));
}
```

The separation makes code easier to read and reason about.

Reference: [Clean Code, Chapter 3: Functions](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
