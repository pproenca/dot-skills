---
title: Express Yourself in Code, Not Comments
impact: CRITICAL
impactDescription: eliminates stale comment risk
tags: cmt, self-documenting, refactoring, clarity
---

## Express Yourself in Code, Not Comments

In many cases, creating a function that says the same thing as the comment you wanted to write is better. Code can be refactored to be self-explanatory.

**Incorrect (comment explains obscure code):**

```java
// Check to see if the employee is eligible for full benefits
if ((employee.flags & HOURLY_FLAG) && (employee.age > 65)) {
    // ...
}

// Add 30 days to the current date
Date newDate = new Date(currentDate.getTime() + (30L * 24 * 60 * 60 * 1000));

// Returns true if the string contains only digits
boolean result = str.matches("[0-9]+");
```

**Correct (code expresses intent):**

```java
if (employee.isEligibleForFullBenefits()) {
    // ...
}

// In Employee class:
public boolean isEligibleForFullBenefits() {
    return isHourlyWorker() && age > RETIREMENT_AGE;
}

Date newDate = currentDate.plusDays(30);

boolean result = StringUtils.isNumeric(str);
// Or define your own:
boolean result = containsOnlyDigits(str);
```

**Benefits:**
- Function names are searchable
- Functions can be tested
- Code documents itself
- No risk of comment becoming stale

Reference: [Clean Code, Chapter 4: Comments](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
