---
title: Use Pronounceable Names
impact: HIGH
impactDescription: enables verbal communication about code
tags: name, pronounceable, communication, readability
---

## Use Pronounceable Names

Use pronounceable names. If you cannot pronounce a name, you cannot discuss it without sounding foolish. Programming is a social activity; names should facilitate discussion.

**Incorrect (unpronounceable abbreviations):**

```java
class DtaRcrd102 {
    private Date genymdhms;  // generation year, month, day, hour, minute, second
    private Date modymdhms;
    private final String pszqint = "102";
}

// In conversation: "Hey, look at this dee-tee-ay-arr-cee-arr-dee"
```

**Correct (pronounceable names):**

```java
class Customer {
    private Date generationTimestamp;
    private Date modificationTimestamp;
    private final String recordId = "102";
}

// In conversation: "Hey, look at this Customer record"
```

The pronounceable version enables natural conversation: "Hey, when did we modify this customer's generation timestamp?"

Reference: [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
