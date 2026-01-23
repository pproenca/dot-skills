---
title: Use Noun Phrases for Class Names
impact: MEDIUM-HIGH
impactDescription: eliminates "what does this class do" questions
tags: name, class, noun, identity
---

## Use Noun Phrases for Class Names

Class names should be nouns or noun phrases. A class represents a thing or concept. Avoid verbs, manager-style names, and vague words.

**Incorrect (verbs, vague, or manager-style):**

```java
// Verb as class name
class ProcessPayment {}

// Vague manager names
class Manager {}
class Processor {}
class Data {}
class Info {}

// Unnecessary suffixes
class CustomerManager {}
class AccountProcessor {}
class PaymentHandler {}
```

**Correct (specific noun phrases):**

```java
// Clear nouns representing entities
class Payment {}
class PaymentGateway {}

// Specific, descriptive nouns
class Customer {}
class WikiPage {}
class Account {}
class AddressParser {}

// Role-specific names when needed
class PaymentValidator {}    // Validates payments
class AccountRepository {}   // Stores accounts
```

**When NOT to use this pattern:**

Manager-style names are acceptable when the class genuinely manages a resource lifecycle:
- `ConnectionPool` - manages connection lifecycle
- `ThreadPoolExecutor` - manages thread lifecycle

Reference: [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
