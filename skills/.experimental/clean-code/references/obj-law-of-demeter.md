---
title: Follow the Law of Demeter
impact: MEDIUM-HIGH
impactDescription: prevents hidden dependencies between modules
tags: obj, demeter, coupling, encapsulation
---

## Follow the Law of Demeter

A method should only call methods on: its own object, objects passed as parameters, objects it creates, or its direct component objects. Avoid chained method calls on returned objects.

**Incorrect (train wreck - violates Law of Demeter):**

```java
// Reaches through multiple objects
String outputDir = ctxt.getOptions().getScratchDir().getAbsolutePath();

// Forces knowledge of internal structure
customer.getAddress().getCity().getName();

// Chains expose implementation details
report.getFormatter().getConfiguration().getPageSize();
```

**Correct (respects object boundaries):**

```java
// Option 1: Create a direct method
String outputDir = ctxt.getOutputDirectory();

// Option 2: Tell, don't ask
customer.sendBillingNotice();  // Let customer handle its own address

// Option 3: If data structure, use it directly (no behavior expected)
BufferedOutputStream bos = ctxt.createScratchFileStream(classFileName);
```

**Exception:** The Law of Demeter does not apply to data structures. If `Options`, `ScratchDir`, etc. are just data containers without behavior, the chaining is acceptable:

```java
// Data transfer objects can be chained
final String outputDir = ctxt.options.scratchDir.absolutePath;
```

Reference: [Clean Code, Chapter 6: Objects and Data Structures](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
