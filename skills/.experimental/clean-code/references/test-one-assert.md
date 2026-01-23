---
title: One Assert Per Test
impact: MEDIUM
impactDescription: enables precise failure diagnosis
tags: test, assert, single, focus
---

## One Assert Per Test

Each test should have a single concept and a single assert. When a test fails, you should know exactly what went wrong without reading the entire test.

**Incorrect (multiple asserts, multiple concepts):**

```java
@Test
public void testUserRegistration() {
    User user = userService.register("bob@example.com", "password123");

    assertNotNull(user);
    assertNotNull(user.getId());
    assertEquals("bob@example.com", user.getEmail());
    assertTrue(user.isActive());
    assertNotNull(user.getCreatedAt());
    verify(emailService).sendWelcome("bob@example.com");
    assertEquals(1, userRepository.count());
}
// If this fails, which assertion failed? What concept is broken?
```

**Correct (one concept per test):**

```java
@Test
public void registerShouldCreateUserWithGeneratedId() {
    User user = userService.register("bob@example.com", "password123");

    assertNotNull(user.getId());
}

@Test
public void registerShouldSetUserEmailFromInput() {
    User user = userService.register("bob@example.com", "password123");

    assertEquals("bob@example.com", user.getEmail());
}

@Test
public void registerShouldActivateUserByDefault() {
    User user = userService.register("bob@example.com", "password123");

    assertTrue(user.isActive());
}

@Test
public void registerShouldSendWelcomeEmail() {
    userService.register("bob@example.com", "password123");

    verify(emailService).sendWelcome("bob@example.com");
}
```

**Relaxed guideline:** Minimize the number of asserts per test. Multiple asserts are acceptable when testing a single cohesive concept that requires multiple checks.

Reference: [Clean Code, Chapter 9: Unit Tests](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
