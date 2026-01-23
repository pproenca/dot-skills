---
title: Use Searchable Names
impact: HIGH
impactDescription: enables effective code navigation
tags: name, searchable, constants, refactoring
---

## Use Searchable Names

Single-letter names and numeric constants are hard to locate across a body of text. Longer names trump shorter names, and searchable names trump convenient abbreviations.

**Incorrect (unsearchable):**

```java
for (int j = 0; j < 34; j++) {
    s += (t[j] * 4) / 5;  // What is 34? What is 4? What is 5?
}
```

**Correct (searchable and meaningful):**

```java
int realDaysPerIdealDay = 4;
final int WORK_DAYS_PER_WEEK = 5;
final int NUMBER_OF_TASKS = 34;

int sum = 0;
for (int taskIndex = 0; taskIndex < NUMBER_OF_TASKS; taskIndex++) {
    int realTaskDays = taskEstimate[taskIndex] * realDaysPerIdealDay;
    int realTaskWeeks = realTaskDays / WORK_DAYS_PER_WEEK;
    sum += realTaskWeeks;
}
```

Now you can search for `WORK_DAYS_PER_WEEK` and find every place it is used. Try searching for `5` in a large codebase.

**Exception:** Single-letter names are acceptable only as local variables in short methods. The length of a name should correspond to the size of its scope.

Reference: [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
