---
title: Distinguish Symptoms from Causes
impact: HIGH
impactDescription: prevents fixing the wrong thing
tags: rca, symptoms, causes, diagnosis
---

## Distinguish Symptoms from Causes

A symptom is what you observe (crash, wrong output, slow response). A cause is why it happens (null reference, wrong algorithm, missing index). Fixing symptoms without finding causes leads to recurring bugs.

**Incorrect (treating symptoms as causes):**

```java
// Bug: NullPointerException in getUserName()
// "Fix": Add null check where crash occurs

public String getUserName(int userId) {
    User user = userRepository.findById(userId);
    // Symptom fix: Hide the null, return default
    if (user == null) {
        return "Unknown";  // Bug hidden, not fixed
    }
    return user.getName();
}

// Problem: Why is user null? That's the real bug!
// Users still can't see their name, they just see "Unknown"
```

**Correct (tracing symptom to cause):**

```java
// Bug: NullPointerException in getUserName()
// Analysis: Why is user null?

public String getUserName(int userId) {
    User user = userRepository.findById(userId);

    // Investigation: When is user null?
    // - User ID 12345 returns null
    // - User 12345 exists in database
    // - But userRepository uses cache
    // - Cache eviction happened during user creation
    // ROOT CAUSE: Race condition in cache population

    return user.getName();
}

// Real fix: Fix cache population race condition
// userRepository.java line 78:
public User findById(int userId) {
    return cache.computeIfAbsent(userId, this::loadFromDatabase);
    // computeIfAbsent is atomic, prevents race condition
}
```

**Symptom vs Cause examples:**
| Symptom | Possible Cause |
|---------|----------------|
| 500 error | Null reference, database down, timeout |
| Slow response | Missing index, N+1 query, memory leak |
| Wrong output | Off-by-one, type coercion, timezone issue |

Reference: [TechTarget - Root Cause Analysis of Software Defects](https://www.techtarget.com/searchsoftwarequality/tip/How-to-handle-root-cause-analysis-of-software-defects)
