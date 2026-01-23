---
title: Use Verb Phrases for Method Names
impact: MEDIUM-HIGH
impactDescription: reduces "what does this method do" lookups by 80%
tags: name, method, verb, action
---

## Use Verb Phrases for Method Names

Method names should be verbs or verb phrases. Methods do things, so their names should say what they do. Follow JavaBean conventions for accessors and mutators.

**Incorrect (non-verb or unclear):**

```java
// Noun names for methods
public String name() {}
public int size() {}  // Acceptable for collections

// Unclear action
public void customer() {}  // Does what to customer?

// Missing verb
public boolean valid() {}
```

**Correct (verb phrases):**

```java
// Clear verb phrases
public void postPayment() {}
public void deletePage() {}
public void saveCustomer() {}

// Accessors, mutators, predicates follow conventions
public String getName() {}
public void setName(String name) {}
public boolean isPosted() {}
public boolean hasPermission() {}

// Static factory methods describe what is created
Complex fulcrumPoint = Complex.fromRealNumber(23.0);
```

Use `get`, `set`, `is`, and `has` prefixes consistently for accessors, mutators, and predicates.

Reference: [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
