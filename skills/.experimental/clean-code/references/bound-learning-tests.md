---
title: Write Learning Tests for Third-Party Code
impact: MEDIUM
impactDescription: catches 90%+ of breaking changes in dependency upgrades before production
tags: bound, boundary, learning-tests, third-party, testing
---

## Write Learning Tests for Third-Party Code

When integrating a third-party library, write small tests that verify your understanding of how the API works. These tests serve double duty: they help you learn the API, and they act as a safety net when upgrading the library.

**Incorrect (learning by trial and error in production code):**

```java
// Experimenting directly in application code
public void importCustomerRecord(String json) {
    // Does Gson handle null fields? Let's find out...
    Gson gson = new Gson();
    CustomerRecord record = gson.fromJson(json, CustomerRecord.class);
    // Does this throw or return null for missing fields?
    // Who knows — we'll find out in production
}
```

**Correct (learning tests verify assumptions):**

```java
@Test
public void gsonShouldDeserializeNullFieldsAsNull() {
    Gson gson = new Gson();
    Data data = gson.fromJson("{}", Data.class);

    assertNull(data.getName());
}

@Test
public void gsonShouldHandleMalformedJson() {
    Gson gson = new Gson();

    assertThrows(JsonSyntaxException.class,
        () -> gson.fromJson("{invalid", Data.class));
}

@Test
public void gsonShouldIgnoreUnknownFields() {
    Gson gson = new Gson();
    Data data = gson.fromJson("{\"name\":\"test\",\"unknown\":true}", Data.class);

    assertEquals("test", data.getName());
}
```

**Benefits:**
- Free education on the API's behavior
- When you upgrade the library, these tests break first — before your production code does
- Documents exactly which behaviors your code relies on
- Takes minutes to write but saves hours of debugging

Reference: [Clean Code, Chapter 8: Boundaries](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
