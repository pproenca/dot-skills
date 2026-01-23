---
title: Avoid Disinformation in Names
impact: CRITICAL
impactDescription: prevents incorrect mental models
tags: name, disinformation, misleading, types
---

## Avoid Disinformation in Names

Avoid names that encode false information. Do not refer to a grouping as a "List" unless it is actually a List. Avoid names that vary in small ways that are hard to distinguish.

**Incorrect (misleading type information):**

```java
// Not actually a List, it's a Map
private Map<String, Account> accountList;

// These look almost identical - easy to confuse
private String XYZControllerForEfficientHandlingOfStrings;
private String XYZControllerForEfficientStorageOfStrings;

// Lowercase L looks like 1, uppercase O looks like 0
int a = l;
if (O == l)
    a = O1;
```

**Correct (accurate and distinguishable):**

```java
// Accurately describes the data structure
private Map<String, Account> accountsByName;

// Clearly distinguishable names
private String stringProcessingController;
private String stringStorageController;

// Clear variable names
int result = leftValue;
if (originalValue == leftValue)
    result = outputValue;
```

Reference: [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
