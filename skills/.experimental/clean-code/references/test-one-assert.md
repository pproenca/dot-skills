---
title: One Concept Per Test
impact: MEDIUM
impactDescription: enables precise failure diagnosis
tags: test, assert, concept, focus
---

## One Concept Per Test

Each test should verify a single concept or behavior. Multiple assertions are fine when they all verify different aspects of that one concept. What you want to avoid is testing unrelated concerns in a single test.

**Incorrect (multiple unrelated concepts in one test):**

```java
@Test
public void testUserRegistration() {
    User user = userService.register("bob@example.com", "password123");

    // Concept 1: user creation
    assertNotNull(user);
    assertNotNull(user.getId());

    // Concept 2: email notification (unrelated to creation details)
    verify(emailService).sendWelcome("bob@example.com");

    // Concept 3: repository state (separate concern)
    assertEquals(1, userRepository.count());
}
// If this fails, which concept is broken? Creation? Email? Persistence?
```

**Correct (one concept per test, multiple assertions are fine):**

```java
@Test
public void registerShouldCreateActiveUserWithGeneratedId() {
    User user = userService.register("bob@example.com", "password123");

    assertNotNull(user.getId());
    assertEquals("bob@example.com", user.getEmail());
    assertTrue(user.isActive());
}

@Test
public void registerShouldSendWelcomeEmail() {
    userService.register("bob@example.com", "password123");

    verify(emailService).sendWelcome("bob@example.com");
}

@Test
public void registerShouldPersistUser() {
    userService.register("bob@example.com", "password123");

    assertEquals(1, userRepository.count());
}
```

The first test has three assertions — that's fine because they all verify a single concept: "the returned user object is correctly constructed." Each test can be understood from its name alone.

**When NOT to split tests:**
- When multiple assertions verify the same behavior from different angles (like checking all fields of a returned object), keep them together — splitting creates duplicate setup and slower test suites.
- When the operation under test has side effects (API calls, DB writes), avoid calling it multiple times just to isolate assertions.

Reference: [Clean Code, Chapter 9: Unit Tests](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
