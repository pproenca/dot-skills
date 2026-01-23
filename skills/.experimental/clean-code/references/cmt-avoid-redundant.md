---
title: Avoid Redundant Comments
impact: HIGH
impactDescription: eliminates noise that obscures important information
tags: cmt, redundant, noise, clutter
---

## Avoid Redundant Comments

A comment that merely restates what the code does is worse than no comment. It adds clutter, becomes stale, and trains readers to ignore comments entirely.

**Incorrect (redundant comments):**

```java
/**
 * The name of the customer
 */
private String customerName;

/**
 * Returns the name
 * @return the name
 */
public String getName() {
    return name;
}

// Check if the account is closed
if (account.isClosed()) {
    // Throw an exception
    throw new AccountClosedException();
}

/**
 * Default constructor
 */
public Account() {
}
```

**Correct (comment only when necessary):**

```java
private String customerName;

public String getName() {
    return name;
}

if (account.isClosed()) {
    throw new AccountClosedException();
}

public Account() {
}

// Comments that add value:

// RFC 2822 date format required by legacy email parser
private static final String DATE_FORMAT = "EEE, dd MMM yyyy HH:mm:ss Z";

// Thread-safe: ConcurrentHashMap handles synchronization
private Map<String, Session> activeSessions = new ConcurrentHashMap<>();
```

**Rule of thumb:** If the comment just repeats the code in English, delete it.

Reference: [Clean Code, Chapter 4: Comments](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
