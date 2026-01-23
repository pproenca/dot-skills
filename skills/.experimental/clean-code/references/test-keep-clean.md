---
title: Keep Tests Clean
impact: MEDIUM
impactDescription: maintains test maintainability over time
tags: test, clean, maintainability, quality
---

## Keep Tests Clean

Test code is just as important as production code. It requires thought, design, and care. If you let tests rot, they become a liability instead of an asset.

**Incorrect (dirty tests):**

```java
@Test
public void test1() {
    // Cryptic, no clear purpose
    S s = new S();
    s.a("x");
    s.b("y");
    assertTrue(s.c());
    s.d();
    assertEquals("xy", s.e());
}

@Test
public void testEverything() {
    // Multiple assertions testing different concepts
    assertNotNull(user);
    assertEquals("Bob", user.getName());
    assertTrue(user.isActive());
    assertEquals(3, user.getOrders().size());
    assertTrue(user.getOrders().get(0).isPaid());
}
```

**Correct (clean, readable tests):**

```java
@Test
public void concatenatingTwoStringsShouldReturnCombinedResult() {
    StringBuffer buffer = new StringBuffer();

    buffer.append("first");
    buffer.append("second");

    assertEquals("firstsecond", buffer.toString());
}

@Test
public void userShouldBeActiveAfterActivation() {
    User user = new User("Bob");

    user.activate();

    assertTrue(user.isActive());
}

@Test
public void activatingUserShouldSendWelcomeEmail() {
    User user = new User("Bob");
    EmailService emailService = mock(EmailService.class);

    user.activate(emailService);

    verify(emailService).sendWelcome(user.getEmail());
}
```

**Qualities of clean tests:**
- Readable: Clear setup, action, assertion
- One concept per test
- Descriptive names explaining what is being tested

Reference: [Clean Code, Chapter 9: Unit Tests](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
