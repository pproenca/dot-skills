---
title: Use Warning Comments for Consequences
impact: MEDIUM
impactDescription: prevents costly mistakes by future maintainers
tags: cmt, warning, consequences, safety
---

## Use Warning Comments for Consequences

Comments that warn other programmers about certain consequences are valuable. They prevent others from making mistakes that have non-obvious impacts.

**Incorrect (no warning about hidden dangers):**

```java
public static SimpleDateFormat makeStandardDateFormat() {
    return new SimpleDateFormat("yyyy-MM-dd");
}

public void runExpensiveOperation() {
    // Process all historical data
    processAllRecords();
}

@Test
public void testWithRealDatabase() {
    database.connect();
    // ...
}
```

**Correct (warnings prevent mistakes):**

```java
// SimpleDateFormat is not thread-safe. Create a new instance for each thread
// or use DateTimeFormatter instead (Java 8+)
public static SimpleDateFormat makeStandardDateFormat() {
    return new SimpleDateFormat("yyyy-MM-dd");
}

// WARNING: This operation takes ~30 minutes on production data
// and consumes significant memory. Run only during maintenance windows.
public void runExpensiveOperation() {
    processAllRecords();
}

// Don't run this test unless you have several hours to kill.
// Requires real database connection and processes 10M+ records.
@Ignore("Long-running integration test")
@Test
public void testWithRealDatabase() {
    database.connect();
    // ...
}
```

**Good warnings include:**
- Thread-safety concerns
- Performance implications
- External dependencies or side effects
- Security considerations

Reference: [Clean Code, Chapter 4: Comments](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
