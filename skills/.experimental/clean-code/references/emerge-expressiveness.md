---
title: Maximize Expressiveness
impact: MEDIUM-HIGH
impactDescription: reduces time to understand unfamiliar code by 50%+
tags: emerge, expressiveness, readability, maintenance
---

## Maximize Expressiveness

The majority of the cost of a software project is in long-term maintenance. Write code for the reader, not the writer. The clearer the author can make the code, the less time others will spend understanding it.

**Incorrect (clever but opaque):**

```java
// Bit manipulation for no reason
public boolean isWeekend(int day) {
    return ((day & 0x6) == day) && (day > 0);
}

// Terse variable names in complex logic
public int calc(int[] a, int n) {
    int r = 0;
    for (int i = 0; i < n; i++)
        r = Math.max(r, a[i] - (i > 0 ? a[i-1] : 0));
    return r;
}
```

**Correct (clear and expressive):**

```java
public boolean isWeekend(DayOfWeek day) {
    return day == DayOfWeek.SATURDAY || day == DayOfWeek.SUNDAY;
}

public int findMaxDailyGain(int[] dailyPrices, int numberOfDays) {
    int maxGain = 0;
    for (int day = 1; day < numberOfDays; day++) {
        int dailyChange = dailyPrices[day] - dailyPrices[day - 1];
        maxGain = Math.max(maxGain, dailyChange);
    }
    return maxGain;
}
```

**Techniques for expressiveness:**
- Choose good names (the single most effective technique)
- Keep functions and classes small and focused
- Use standard patterns and nomenclature — when you use the Strategy pattern, name the class with "Strategy" so readers recognize the intent
- Write well-crafted unit tests — tests are documentation by example

Reference: [Clean Code, Chapter 12: Emergence](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
